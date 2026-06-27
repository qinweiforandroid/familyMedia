#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PID_DIR="$ROOT_DIR/.run/pids"
MYSQLADMIN_BIN="$(command -v mysqladmin || true)"

"$SCRIPT_DIR/stop-admin-web.sh"
"$SCRIPT_DIR/stop-backend.sh"
"$SCRIPT_DIR/stop-minio.sh"

if [[ -n "$MYSQLADMIN_BIN" ]] && "$MYSQLADMIN_BIN" -uroot ping >/dev/null 2>&1; then
  "$MYSQLADMIN_BIN" -uroot shutdown
  echo "MySQL: shutdown requested"
fi
rm -f "$PID_DIR/mysql.pid"
