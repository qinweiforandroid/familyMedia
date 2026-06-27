#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

require_dir "$FRONTEND_DIR" "Admin web"
require_node_runtime
require_file "$FRONTEND_DIR/package.json" "Admin web package.json"

cd "$FRONTEND_DIR"
"$NPM_BIN" run build
