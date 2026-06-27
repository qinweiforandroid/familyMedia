#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/workspace.repos.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Workspace repo config not found: $CONFIG_FILE" >&2
  exit 1
fi

node <<'NODE'
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const rootDir = process.cwd();
const configPath = path.join(rootDir, "workspace.repos.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));

for (const repo of config.repos || []) {
  const repoPath = path.join(rootDir, repo.path);
  const repoDir = path.dirname(repoPath);

  if (!fs.existsSync(repoDir)) {
    fs.mkdirSync(repoDir, { recursive: true });
  }

  if (!fs.existsSync(repoPath)) {
    console.log(`[clone] ${repo.name} -> ${repo.path} (${repo.branch})`);
    execSync(`git clone --branch ${repo.branch} ${repo.url} ${repo.path}`, {
      cwd: rootDir,
      stdio: "inherit",
    });
    continue;
  }

  if (fs.existsSync(path.join(repoPath, ".git"))) {
    console.log(`[skip] ${repo.name} already exists at ${repo.path}`);
    continue;
  }

  console.log(`[warn] ${repo.name} path exists but is not a git repo: ${repo.path}`);
}
NODE
