#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

stop_from_pidfile "$FRONTEND_PID_FILE" "Admin web"
