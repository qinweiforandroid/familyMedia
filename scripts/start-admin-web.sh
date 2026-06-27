#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

require_dir "$FRONTEND_DIR" "Admin web"
require_node_runtime

if is_listening 5173; then
  echo "Frontend is already running on 5173"
  exit 0
fi

echo "Starting admin web..."
(
  cd "$FRONTEND_DIR"
  nohup "$NODE_BIN" node_modules/vite/bin/vite.js --host 0.0.0.0 --port 5173 \
    >"$FRONTEND_LOG" 2>&1 &
  echo $! >"$FRONTEND_PID_FILE"
)

wait_for_port 5173 "Frontend"

echo "Admin web is ready:"
echo "  URL:  http://127.0.0.1:5173/"
echo "  Log:  $FRONTEND_LOG"
