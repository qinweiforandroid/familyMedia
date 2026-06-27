# AI Repo Guide

## Goal

Help AI tools quickly build the right mental model of this workspace without wasting time in runtime artifacts.

## Quick Summary

- Backend lives in `apps/backend`
- Admin frontend lives in `apps/admin-web`
- Local MinIO binaries live in `infra/minio`
- Local MinIO object data lives in `storage/minio-data`
- Operational entry points live in `scripts`

## Best First Reads

1. `AGENTS.md`
2. `README.md`
3. `docs/architecture/repo-map.md`

## Where To Start By Task

### Add or fix backend behavior

- `apps/backend/src/main/java`
- `apps/backend/src/main/resources`
- `apps/backend/http`

### Add or fix admin UI

- `apps/admin-web/src/pages`
- `apps/admin-web/src/api`
- `apps/admin-web/src/router`

### Investigate uploads or storage

- `scripts/start-minio.sh`
- `infra/minio`
- `storage/minio-data`
- backend storage config under `apps/backend/src/main/resources`

### Understand local startup

- `scripts/start-stack.sh`
- `scripts/start-minio.sh`
- `scripts/status-stack.sh`
- `scripts/stop-stack.sh`

## Folders To Deprioritize

These usually add noise during analysis:

- `code/build`
- `code/.gradle`
- `code/log`
- `apps/admin-web/node_modules`
- `.run`
- system `node` / `npm`
- `infra/minio/minio.parts`
- `storage/minio-data/.minio.sys`

## Common Mistakes To Avoid

- Do not assume `storage/minio-data` is source code.
- Do not start from `node_modules` when debugging frontend behavior.
- Do not edit generated files before checking their source definitions.
- Do not assume operational scripts and workspace layout are fully normalized yet; verify paths before refactoring.
