#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

require_dir "$BACKEND_DIR" "Backend"
require_java_home

if is_listening 8080; then
  echo "Backend is already running on 8080"
  exit 0
fi

echo "Starting backend..."
(
  cd "$BACKEND_DIR"
  nohup ./gradlew -Dorg.gradle.java.home="$JAVA17_HOME" bootRun --args='--spring.profiles.active=produce' \
    >"$BACKEND_LOG" 2>&1 &
  echo $! >"$BACKEND_PID_FILE"
)

wait_for_port 8080 "Backend"

echo "Backend is ready:"
echo "  URL:  http://127.0.0.1:8080/code"
echo "  Log:  $BACKEND_LOG"
