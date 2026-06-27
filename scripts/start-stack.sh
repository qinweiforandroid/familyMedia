#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUN_DIR="$ROOT_DIR/.run"
LOG_DIR="$RUN_DIR/logs"
PID_DIR="$RUN_DIR/pids"

MYSQL_LOG="$LOG_DIR/mysql.log"
MYSQL_PID_FILE="$PID_DIR/mysql.pid"
MYSQLADMIN_BIN="$(command -v mysqladmin || true)"
MYSQL_BIN="$(command -v mysql || true)"
MYSQLD_SAFE_BIN="$(command -v mysqld_safe || true)"
MYSQL_DATA_DIR="${MYSQL_DATA_DIR:-}"

mkdir -p "$LOG_DIR" "$PID_DIR"
source "$SCRIPT_DIR/app-common.sh"

start_mysql() {
  if is_listening 3306; then
    echo "MySQL is already running on 3306"
    return
  fi

  echo "Starting MySQL..."
  if [[ -z "$MYSQLD_SAFE_BIN" ]]; then
    echo "mysqld_safe not found in PATH" >&2
    exit 1
  fi
  (
    cd "$ROOT_DIR"
    if [[ -n "$MYSQL_DATA_DIR" ]]; then
      nohup "$MYSQLD_SAFE_BIN" --datadir="$MYSQL_DATA_DIR" >"$MYSQL_LOG" 2>&1 &
    else
      nohup "$MYSQLD_SAFE_BIN" >"$MYSQL_LOG" 2>&1 &
    fi
    echo $! >"$MYSQL_PID_FILE"
  )
}

ensure_mysql_schema() {
  if [[ -z "$MYSQL_BIN" ]]; then
    echo "mysql client not found in PATH" >&2
    exit 1
  fi
  "$MYSQL_BIN" -uroot -e "create database if not exists db_code default character set utf8mb4 collate utf8mb4_unicode_ci;"
}

ensure_minio_bucket() {
  python3 - <<'PY'
import datetime
import hashlib
import hmac
import http.client

access_key = 'minioadmin'
secret_key = 'minioadmin'
bucket = 'media'
host = '127.0.0.1:9000'
region = 'us-east-1'
service = 's3'
method = 'PUT'
canonical_uri = f'/{bucket}'
payload_hash = hashlib.sha256(b'').hexdigest()
now = datetime.datetime.utcnow()
amz_date = now.strftime('%Y%m%dT%H%M%SZ')
date_stamp = now.strftime('%Y%m%d')
canonical_headers = f'host:{host}\nx-amz-content-sha256:{payload_hash}\nx-amz-date:{amz_date}\n'
signed_headers = 'host;x-amz-content-sha256;x-amz-date'
canonical_request = '\n'.join([method, canonical_uri, '', canonical_headers, signed_headers, payload_hash])
algorithm = 'AWS4-HMAC-SHA256'
credential_scope = f'{date_stamp}/{region}/{service}/aws4_request'
string_to_sign = '\n'.join([algorithm, amz_date, credential_scope, hashlib.sha256(canonical_request.encode()).hexdigest()])

def sign(key, msg):
    return hmac.new(key, msg.encode(), hashlib.sha256).digest()

k_date = sign(('AWS4' + secret_key).encode(), date_stamp)
k_region = sign(k_date, region)
k_service = sign(k_region, service)
k_signing = sign(k_service, 'aws4_request')
signature = hmac.new(k_signing, string_to_sign.encode(), hashlib.sha256).hexdigest()
authorization = (
    f'{algorithm} Credential={access_key}/{credential_scope}, '
    f'SignedHeaders={signed_headers}, Signature={signature}'
)

conn = http.client.HTTPConnection('127.0.0.1', 9000, timeout=30)
conn.request(method, canonical_uri, body=b'', headers={
    'Host': host,
    'x-amz-content-sha256': payload_hash,
    'x-amz-date': amz_date,
    'Authorization': authorization,
})
resp = conn.getresponse()
resp.read()
if resp.status not in (200, 409):
    raise SystemExit(f'Failed to ensure media bucket, status={resp.status}')
PY
}

require_dir "$BACKEND_DIR" "Backend"
require_dir "$FRONTEND_DIR" "Frontend"
require_node_runtime
require_java_home

start_mysql
wait_for_port 3306 "MySQL"
ensure_mysql_schema

"$SCRIPT_DIR/start-minio.sh"
wait_for_port 9000 "MinIO"
ensure_minio_bucket

"$SCRIPT_DIR/start-backend.sh"

"$SCRIPT_DIR/start-admin-web.sh"

echo ""
echo "Stack is ready:"
echo "  MySQL:    127.0.0.1:3306"
echo "  Backend:  http://127.0.0.1:8080/code"
echo "  Frontend: http://127.0.0.1:5173/"
echo "  MinIO:    http://127.0.0.1:9000"
echo "  Console:  http://127.0.0.1:9001"
echo ""
echo "Logs:"
echo "  $MYSQL_LOG"
echo "  $BACKEND_LOG"
echo "  $FRONTEND_LOG"
echo "  $LOG_DIR/minio.log"
