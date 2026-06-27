#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

check_port() {
  local port="$1"
  local name="$2"
  if is_listening "$port"; then
    echo "$name: running on $port"
  else
    echo "$name: stopped"
  fi
}

check_port 8080 "Backend"
check_port 5173 "Admin web"
