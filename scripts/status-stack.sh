#!/bin/zsh

set -euo pipefail

check_port() {
  local port="$1"
  local name="$2"
  if lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "$name: running on $port"
  else
    echo "$name: stopped"
  fi
}

check_port 9000 "MinIO"
check_port 9001 "MinIO Console"
check_port 3306 "MySQL"
check_port 8080 "Backend"
check_port 5173 "Frontend"
