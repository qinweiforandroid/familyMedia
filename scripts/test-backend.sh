#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/app-common.sh"

require_dir "$BACKEND_DIR" "Backend"
require_file "$BACKEND_DIR/gradlew" "Gradle wrapper"

cd "$BACKEND_DIR"
./gradlew test
