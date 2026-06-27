#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

stop_from_pidfile "$BACKEND_PID_FILE" "Backend"
