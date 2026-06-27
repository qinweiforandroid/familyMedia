#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"
source "$SCRIPT_DIR/minio-common.sh"

MYSQLADMIN_BIN="$(command -v mysqladmin || true)"

print_ok() {
  echo "[OK] $1"
}

print_warn() {
  echo "[WARN] $1"
}

check_dir() {
  local path="$1"
  local label="$2"
  if [[ -d "$path" ]]; then
    print_ok "$label directory exists: $path"
  else
    print_warn "$label directory missing: $path"
  fi
}

check_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    print_ok "$label file exists: $path"
  else
    print_warn "$label file missing: $path"
  fi
}

check_port() {
  local port="$1"
  local label="$2"
  if lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    print_ok "$label listening on $port"
  else
    print_warn "$label not listening on $port"
  fi
}

check_pid_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    local pid
    pid="$(cat "$path" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
      print_ok "$label pid file exists and process is alive: $path"
    else
      print_warn "$label pid file exists but process is not running: $path"
    fi
  else
    print_warn "$label pid file missing: $path"
  fi
}

check_log_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    print_ok "$label log exists: $path"
  else
    print_warn "$label log missing: $path"
  fi
}

echo "== Workspace =="
check_dir "$ROOT_DIR/apps/backend" "Backend"
check_dir "$ROOT_DIR/apps/admin-web" "Admin web"
check_dir "$ROOT_DIR/apps/android" "Android"
check_dir "$ROOT_DIR/infra/minio" "MinIO infra"
check_dir "$ROOT_DIR/storage/minio-data" "MinIO data"

echo ""
echo "== Runtime Files =="
detect_java_home
detect_node_runtime
check_file "$MINIO_BIN" "MinIO binary"
check_file "$ROOT_DIR/apps/backend/gradlew" "Gradle wrapper"
check_file "$ROOT_DIR/apps/admin-web/package.json" "Admin web package.json"
if [[ -n "$NODE_BIN" ]]; then
  check_file "$NODE_BIN" "System node"
  if "$NODE_BIN" -v >/dev/null 2>&1; then
    print_ok "System node can execute"
  else
    print_warn "System node exists but cannot execute cleanly"
  fi
else
  print_warn "System node not found in PATH"
fi
if [[ -n "$NPM_BIN" ]]; then
  check_file "$NPM_BIN" "System npm"
  if "$NPM_BIN" -v >/dev/null 2>&1; then
    print_ok "System npm can execute"
  else
    print_warn "System npm exists but cannot execute cleanly"
  fi
else
  print_warn "System npm not found in PATH"
fi
if [[ -n "$JAVA17_HOME" ]]; then
  print_ok "Java home detected: $JAVA17_HOME"
else
  print_warn "Java 17 home could not be detected"
fi
if [[ -n "$MYSQLADMIN_BIN" ]]; then
  check_file "$MYSQLADMIN_BIN" "mysqladmin"
else
  print_warn "mysqladmin not found in PATH"
fi

echo ""
echo "== Ports =="
check_port 3306 "MySQL"
check_port 9000 "MinIO API"
check_port 9001 "MinIO Console"
check_port 8080 "Backend"
check_port 5173 "Admin web"

echo ""
echo "== PID Files =="
check_pid_file "$ROOT_DIR/.run/pids/mysql.pid" "MySQL"
check_pid_file "$MINIO_PID_FILE" "MinIO"
check_pid_file "$BACKEND_PID_FILE" "Backend"
check_pid_file "$FRONTEND_PID_FILE" "Admin web"

echo ""
echo "== Logs =="
check_log_file "$ROOT_DIR/.run/logs/mysql.log" "MySQL"
check_log_file "$MINIO_LOG" "MinIO"
check_log_file "$BACKEND_LOG" "Backend"
check_log_file "$FRONTEND_LOG" "Admin web"

echo ""
echo "== Notes =="
if minio_has_provenance_attr; then
  print_warn "MinIO binary still has com.apple.provenance attribute"
else
  print_ok "MinIO binary provenance attribute not detected"
fi
if [[ -z "$NODE_BIN" || -z "$NPM_BIN" ]]; then
  print_warn "Frontend scripts now depend on system Node.js and npm"
fi
