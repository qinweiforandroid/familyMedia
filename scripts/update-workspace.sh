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

  if (!fs.existsSync(repoPath) || !fs.existsSync(path.join(repoPath, ".git"))) {
    console.log(`[skip] ${repo.name} missing local git repo at ${repo.path}`);
    continue;
  }

  console.log(`[update] ${repo.name} -> ${repo.branch}`);
  execSync(`git checkout ${repo.branch}`, {
    cwd: repoPath,
    stdio: "inherit",
  });
  execSync(`git pull --ff-only origin ${repo.branch}`, {
    cwd: repoPath,
    stdio: "inherit",
  });
}
NODE
