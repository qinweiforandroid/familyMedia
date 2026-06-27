#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/apps/backend"
FRONTEND_DIR="$ROOT_DIR/apps/admin-web"
NODE_BIN="$(command -v node || true)"
NPM_BIN="$(command -v npm || true)"
JAVA_HOME_BIN="/usr/libexec/java_home"
JAVA17_HOME=""
RUN_DIR="$ROOT_DIR/.run"
LOG_DIR="$RUN_DIR/logs"
PID_DIR="$RUN_DIR/pids"

BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"

BACKEND_PID_FILE="$PID_DIR/backend.pid"
FRONTEND_PID_FILE="$PID_DIR/frontend.pid"

mkdir -p "$LOG_DIR" "$PID_DIR"

is_listening() {
  local port="$1"
  lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
}

require_dir() {
  local path="$1"
  local name="$2"
  if [[ ! -d "$path" ]]; then
    echo "$name directory not found: $path" >&2
    exit 1
  fi
}

require_file() {
  local path="$1"
  local name="$2"
  if [[ ! -f "$path" ]]; then
    echo "$name file not found: $path" >&2
    exit 1
  fi
}

detect_node_runtime() {
  NODE_BIN="${NODE_BIN:-$(command -v node || true)}"
  NPM_BIN="${NPM_BIN:-$(command -v npm || true)}"
}

require_node_runtime() {
  detect_node_runtime
  if [[ -z "$NODE_BIN" ]]; then
    echo "System node not found in PATH. Please install or fix your Node.js environment." >&2
    exit 1
  fi
  if [[ -z "$NPM_BIN" ]]; then
    echo "System npm not found in PATH. Please install or fix your Node.js environment." >&2
    exit 1
  fi
  if ! "$NODE_BIN" -v >/dev/null 2>&1; then
    echo "System node exists but cannot run. Please repair or upgrade your Node.js installation." >&2
    exit 1
  fi
  if ! "$NPM_BIN" -v >/dev/null 2>&1; then
    echo "System npm exists but cannot run. Please repair or upgrade your Node.js installation." >&2
    exit 1
  fi
}

wait_for_port() {
  local port="$1"
  local name="$2"
  local tries="${3:-60}"
  local i=0
  while (( i < tries )); do
    if is_listening "$port"; then
      echo "$name is ready on port $port"
      return 0
    fi
    sleep 1
    ((i += 1))
  done
  echo "$name did not become ready on port $port" >&2
  return 1
}

stop_from_pidfile() {
  local pid_file="$1"
  local name="$2"
  if [[ ! -f "$pid_file" ]]; then
    echo "$name: no pid file"
    return 0
  fi

  local pid
  pid="$(cat "$pid_file")"
  if kill -0 "$pid" >/dev/null 2>&1; then
    kill "$pid"
    echo "$name: stopped pid $pid"
  else
    echo "$name: pid $pid not running"
  fi
  rm -f "$pid_file"
}

show_log_file() {
  local log_file="$1"
  local name="$2"
  if [[ ! -f "$log_file" ]]; then
    echo "$name log not found: $log_file" >&2
    exit 1
  fi
  tail -n 50 "$log_file"
}

detect_java_home() {
  if [[ -n "$JAVA17_HOME" ]]; then
    return 0
  fi

  if [[ -x "$JAVA_HOME_BIN" ]]; then
    JAVA17_HOME="$("$JAVA_HOME_BIN" -v 17 2>/dev/null || true)"
  fi

  if [[ -z "$JAVA17_HOME" ]] && command -v java >/dev/null 2>&1; then
    local java_bin
    java_bin="$(command -v java)"
    if [[ -n "$java_bin" ]]; then
      JAVA17_HOME="$(cd "$(dirname "$java_bin")/.." && pwd)"
    fi
  fi
}

require_java_home() {
  detect_java_home
  if [[ -z "$JAVA17_HOME" ]]; then
    echo "Java 17 home could not be detected. Install Java 17 or configure /usr/libexec/java_home." >&2
    exit 1
  fi
}
