# AGENTS.md

## Project Overview

This workspace is a local development hub for a family media system. It contains:

- `apps/backend`: Java Spring Boot backend
- `apps/admin-web`: Vue 3 + Vite admin frontend
- `apps/android`: Android client workspace area
- `scripts`: local environment control scripts
- `infra/minio`: local MinIO binaries and helper artifacts
- `storage/minio-data`: local MinIO object-storage data
- system `node` / `npm`: required for admin-web scripts and builds

## How To Read This Repo

When you are asked to understand or modify the project, read in this order:

1. `README.md`
2. `docs/architecture/repo-map.md`
3. `scripts/start-stack.sh`
4. Backend or frontend source depending on the task

## Main Entry Points

- Backend source: `apps/backend/src/main`
- Backend config: `apps/backend/src/main/resources`
- Backend SQL docs: `apps/backend/doc/sql`
- Backend design docs: `apps/backend/doc/design`
- Backend history docs: `apps/backend/doc/history`
- Backend HTTP examples: `apps/backend/http`
- Frontend source: `apps/admin-web/src`
- Frontend routes: `apps/admin-web/src/router`
- Frontend pages: `apps/admin-web/src/pages`
- Frontend API layer: `apps/admin-web/src/api`

## Local Runtime And Infra

- MinIO data: `storage/minio-data`
- MinIO binary: `infra/minio/minio`
- MinIO scripts: `scripts/start-minio.sh`, `scripts/stop-minio.sh`
- Stack scripts: `scripts/start-stack.sh`, `scripts/status-stack.sh`, `scripts/stop-stack.sh`

## Important Ports

- MySQL: `3306`
- Backend: `8080`
- Frontend: `5173`
- MinIO API: `9000`
- MinIO Console: `9001`

## Rules For AI Agents

- Prefer reading `apps/backend/src/main` and `apps/admin-web/src` before exploring generated or runtime directories.
- Do not treat `node_modules`, `build`, `.gradle`, `.run`, `log`, or `storage/minio-data/.minio.sys` as primary source code.
- Avoid editing object-storage data under `storage/minio-data`.
- Treat `scripts/` as operational automation, not business logic.
- If a task is about uploads, media assets, or file storage, inspect both backend storage config and `infra/minio` plus `storage/minio-data`.
- If a task is about admin UI behavior, start from `apps/admin-web/src/pages` and `apps/admin-web/src/api`.
- If a task is about database or backend APIs, start from `apps/backend/src/main/resources/application-*.yml`, `apps/backend/src/main/java`, and `apps/backend/http`.

## Ignore-First Directories

These directories usually add noise and should be deprioritized unless the task is explicitly about generated output or archived local artifacts:

- `.run`
- `storage/minio-data`
- `apps/backend/build`
- `apps/backend/.gradle`
- `apps/backend/log`
- `apps/admin-web/node_modules`

## Known Context

- The current root `README.md` is the main human-facing local setup guide.
- Some operational paths in scripts may point to environment-specific locations and should be verified before broader refactors.
- `apps/android` currently does not expose a clear checked-in app structure at the top level, so treat it as incomplete until inspected further.
