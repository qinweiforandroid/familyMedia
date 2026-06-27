#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/minio-common.sh"

if [[ ! -f "$MINIO_PID_FILE" ]]; then
  echo "MinIO: no pid file"
  exit 0
fi

pid="$(cat "$MINIO_PID_FILE")"
if kill -0 "$pid" >/dev/null 2>&1; then
  kill "$pid"
  echo "MinIO: stopped pid $pid"
else
  echo "MinIO: pid $pid not running"
fi

rm -f "$MINIO_PID_FILE"
