#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/minio-common.sh"

if [[ ! -x "$MINIO_BIN" ]]; then
  echo "MinIO binary not found or not executable: $MINIO_BIN" >&2
  exit 1
fi

if minio_is_listening; then
  echo "MinIO is already running on 9000"
  exit 0
fi

echo "Starting MinIO from $MINIO_DIR..."
(
  cd "$ROOT_DIR"
  MINIO_ROOT_USER="$MINIO_ROOT_USER" \
  MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
  nohup "$MINIO_BIN" server "$MINIO_DATA_DIR" --address :9000 --console-address :9001 \
    >"$MINIO_LOG" 2>&1 &
  echo $! >"$MINIO_PID_FILE"
)

for _ in {1..30}; do
  if minio_is_listening; then
    echo "MinIO is ready:"
    echo "  API:      http://127.0.0.1:9000"
    echo "  Console:  http://127.0.0.1:9001"
    echo "  Log:      $MINIO_LOG"
    exit 0
  fi
  sleep 1
done

echo "MinIO did not become ready on port 9000." >&2
if [[ -f "$MINIO_LOG" ]]; then
  echo "Recent log output:" >&2
  tail -n 20 "$MINIO_LOG" >&2
fi
if minio_has_provenance_attr; then
  echo "Possible macOS gatekeeper fix:" >&2
  echo "  xattr -d com.apple.provenance \"$MINIO_BIN\"" >&2
fi
exit 1
