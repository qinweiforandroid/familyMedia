#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MINIO_DIR="$ROOT_DIR/infra/minio"
MINIO_BIN="$MINIO_DIR/minio"
MINIO_DATA_DIR="$ROOT_DIR/storage/minio-data"
RUN_DIR="$ROOT_DIR/.run"
LOG_DIR="$RUN_DIR/logs"
PID_DIR="$RUN_DIR/pids"
MINIO_LOG="$LOG_DIR/minio.log"
MINIO_PID_FILE="$PID_DIR/minio.pid"
MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"

mkdir -p "$MINIO_DIR" "$MINIO_DATA_DIR" "$LOG_DIR" "$PID_DIR"

minio_is_listening() {
  lsof -iTCP:9000 -sTCP:LISTEN >/dev/null 2>&1
}

minio_has_provenance_attr() {
  xattr "$MINIO_BIN" 2>/dev/null | rg -qx "com\\.apple\\.provenance"
}
