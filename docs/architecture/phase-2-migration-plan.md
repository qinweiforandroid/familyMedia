# Phase 2 Migration Plan

## Goal

Improve repository semantics for humans and AI tools without doing a risky all-at-once refactor.

This phase defines:

- a target directory model
- the order of migration
- the files most likely to break
- what to verify after each step

This document started as a plan. The runtime/infra re-homing and the `apps/*` directory rename described below have now been applied in the workspace.

## Target Structure

Recommended long-term layout:

```text
/Users/qinwei/profile/家庭媒体
├── apps
│   ├── backend
│   ├── admin-web
│   └── android
├── docs
│   ├── ai
│   ├── architecture
│   └── setup
├── infra
│   └── minio
├── runtime
│   └── node
├── scripts
├── storage
│   └── minio-data
├── AGENTS.md
└── README.md
```

## Proposed Mapping

### Business code

- `code` -> `apps/backend`
- `code-admin-web` -> `apps/admin-web`
- `code-android` -> `apps/android`

### Runtime and infrastructure

- `node` -> `runtime/node`
- `storage/miniio/minio` -> `infra/minio/minio`
- `storage/miniio/mc` -> `infra/minio/mc`
- `storage/miniio/minio.new` -> `infra/minio/minio.new`
- `storage/miniio/minio.parts` -> `infra/minio/minio.parts`
- `storage/miniio/minio-data` -> `storage/minio-data`

## Why This Helps

- `apps/*` makes product code discoverable immediately.
- `infra/*` separates infrastructure binaries from business logic.
- `runtime/*` makes downloaded toolchains easier to ignore.
- `storage/*` becomes clearly data-oriented instead of mixed binary-plus-data.
- AI tools can identify high-signal code directories with fewer false positives.

## Historical High-Risk References

These were the main categories that required attention during the migration. They are kept here as a record of what was cleaned up.

### 1. Local startup scripts

Current examples:

- `scripts/start-stack.sh`
- `scripts/minio-common.sh`
- `scripts/start-minio.sh`

Risk:

- These scripts use absolute paths and folder-name assumptions.
- Directory moves will break startup immediately unless scripts are updated first.

### 2. Frontend runtime config

Historical example:

- `code-admin-web/src/api/http.ts`

Risk:

- This file points to the backend base URL and may be used during local validation after the move.
- The HTTP base path `/code` is an API path, not a directory path, so it should not be renamed accidentally during repo cleanup.

### 3. Backend generator and config references

Historical examples:

- `code/src/main/resources/generator/mybatisGenerator.properties`
- `code/src/main/resources/application-*.yml`

Risk:

- Generator configuration still contains historical absolute paths.
- Config files may not break from a repo rename directly, but they often become part of migration cleanup work.

### 4. Historical documentation with absolute paths

Historical examples:

- `code/doc/project-progress-summary-2026-06-25.md`
- `code/doc/project-technical-architecture-and-deployment.md`
- `code/doc/media-management-platform-plan.md`

Risk at the time:

- Many docs referred to old paths such as `/Users/qinwei/code` and `/Users/qinwei/code-admin-web`.
- These references would confuse AI tools even if the actual project structure was improved.

### 5. Tooling metadata

Historical examples:

- `code-admin-web/package.json`
- `code-admin-web/package-lock.json`
- `code-admin-web/README.md`

Risk:

- Package names and local docs still reflect the old folder naming.
- Not functionally critical for boot, but important for semantic consistency.

## Migration Order Used

This is the order used to minimize breakage.

### Step 1. Normalize scripts to relative workspace paths

Before moving directories:

- remove references to `/Users/qinwei/Project/code`
- remove references to `/Users/qinwei/Project/code-admin-web`
- remove assumptions that Node runtime lives at the repo root if it now lives under `node/`

Exit criteria:

- local startup scripts derive paths from workspace-relative locations only
- `start-stack.sh` and `start-minio.sh` still work

Status: completed.

### Step 2. Move runtime-only assets

Move first:

- `node` -> `runtime/node`
- `storage/miniio/minio*` binaries and helper artifacts -> `infra/minio`

Keep stable during this step:

- `storage/minio-data` as the live object-data location

Exit criteria:

- MinIO scripts still start correctly
- Node-based frontend startup still resolves the right binary

Status: completed.

### Step 3. Split MinIO binaries from MinIO data

Move:

- `storage/miniio/minio-data` -> `storage/minio-data`

Keep:

- operational scripts as the compatibility layer

Exit criteria:

- MinIO boots from new binary path and new data path
- docs no longer describe mixed binary/data storage in one folder

Status: completed.

### Step 4. Rename product code directories

Move:

- `code` -> `apps/backend`
- `code-admin-web` -> `apps/admin-web`
- `code-android` -> `apps/android`

Exit criteria:

- primary docs updated
- startup scripts updated
- local developer commands still work

Status: completed.

### Step 5. Clean historical references

Update:

- docs under `code/doc`
- package naming where useful
- generator path settings
- AI guidance docs

Exit criteria:

- old directory names appear only in explicit migration-history notes

Status: completed.

## Verification Checklist

After each migration step, verify:

### Workspace structure

- expected target directories exist
- old paths are removed or intentionally left as temporary compatibility paths

### Startup

- `scripts/start-minio.sh`
- `scripts/start-stack.sh`
- `scripts/status-stack.sh`

### Service checks

- backend reachable on `http://127.0.0.1:8080/code`
- frontend reachable on `http://127.0.0.1:5173/`
- MinIO API reachable on `http://127.0.0.1:9000`
- MinIO Console reachable on `http://127.0.0.1:9001`

### AI readability

- `AGENTS.md` matches the actual directory tree
- `README.md` matches the actual startup commands
- `docs/architecture/repo-map.md` matches the actual directory roles

## Outcome

The workspace now uses:

1. `apps/backend`, `apps/admin-web`, `apps/android`
2. `runtime/node`
3. `infra/minio`
4. `storage/minio-data`

The remaining old names are intentionally limited to migration-history references in this document.
