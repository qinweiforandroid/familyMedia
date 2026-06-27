# Repository Map

## Purpose

This workspace combines application code, local runtime dependencies, and local infrastructure for a family media platform. The goal of this document is to help humans and AI tools quickly answer:

- what each top-level directory is for
- where to start reading for a given task
- which folders are source code versus runtime data

## Top-Level Layout

```text
/Users/qinwei/profile/家庭媒体
├── apps
├── runtime
├── infra
├── scripts
├── storage
├── AGENTS.md
└── README.md
```

## Directory Roles

### `apps/backend`

Java Spring Boot backend.

Important subdirectories:

- `src/main/java`: backend application code
- `src/main/resources`: Spring config, MyBatis mapper XML, logging config
- `src/test`: backend tests
- `doc/sql`: SQL files
- `doc/design`: technical notes, setup notes, project planning docs
- `doc/history`: historical progress summaries
- `http`: HTTP request examples for manual API testing
- `build`: generated artifacts, not primary source
- `log`: runtime logs, not primary source

Use this directory when the task involves:

- API behavior
- database access
- upload logic
- media metadata
- authentication and business rules

### `apps/admin-web`

Vue 3 admin frontend built with Vite.

Important subdirectories:

- `src/pages`: page-level screens
- `src/api`: HTTP client and backend API wrappers
- `src/router`: route definitions
- `src/stores`: client-side state
- `src/layouts`: app shell layout
- `src/styles`: global styles
- `node_modules`: installed dependencies, not primary source

Use this directory when the task involves:

- admin dashboard behavior
- login flow
- file manager UI
- resource and asset management pages

### `apps/android`

Reserved Android workspace area. From the current checked-in top-level structure, it does not yet expose a clear app layout, so it should be inspected case by case before changes.

### `scripts`

Local environment automation.

Current responsibilities:

- start the local stack
- stop the local stack
- start and stop MinIO separately
- report local service status

This folder is operational glue, not core business logic.

### `infra`

Local infrastructure binaries and helper artifacts.

Current usage:

- `infra/minio/minio`: MinIO server binary
- `infra/minio/mc`: MinIO client
- `infra/minio/minio.parts`: helper artifact pieces from binary download

This directory is infrastructure support, not product code.

### `runtime`

Optional local runtime storage.

Current usage:

- may contain local runtime archives, but frontend scripts now prefer system `node` and `npm`

This is support material, not product code.

### `storage`

Local persisted application-support data.

Current usage:

- `storage/minio-data`: persisted object storage data
- `storage/minio-data/.minio.sys`: MinIO internal metadata

Do not treat this directory as application source.

## Source Vs Runtime

### Primary source code

- `apps/backend/src/main`
- `apps/backend/src/test`
- `apps/admin-web/src`
- `scripts`
- `apps/backend/doc/sql`
- `apps/backend/doc/design`
- `apps/backend/doc/history`
- `apps/backend/http`

### Runtime, generated, or downloaded content

- `apps/backend/build`
- `apps/backend/.gradle`
- `apps/backend/log`
- `apps/admin-web/node_modules`
- `.run`
- archived local runtime artifacts if present
- `storage/minio-data`
- `infra/minio/minio.parts`
- `infra/minio/minio.new`

## Recommended Reading Paths

### If the task is backend API related

Read:

1. `apps/backend/src/main/resources/application.yml`
2. `apps/backend/src/main/resources/application-produce.yml`
3. `apps/backend/src/main/java`
4. `apps/backend/src/main/resources/mapper`
5. `apps/backend/http`

### If the task is admin frontend related

Read:

1. `apps/admin-web/src/main.ts`
2. `apps/admin-web/src/router/index.ts`
3. `apps/admin-web/src/pages`
4. `apps/admin-web/src/api`
5. `apps/admin-web/src/stores`

### If the task is file upload or media storage related

Read:

1. `scripts/start-minio.sh`
2. `infra/minio`
3. `storage/minio-data`
4. `apps/backend/src/main/resources/application-*.yml`
5. backend upload and asset code in `apps/backend/src/main/java`

### If the task is local environment setup related

Read:

1. `README.md`
2. `AGENTS.md`
3. `scripts/start-stack.sh`
4. `scripts/start-minio.sh`

## Suggested Future Refactor

To make this workspace even easier for AI tools, a later low-risk structural rename could move toward:

```text
archived local runtime artifacts if present
infra/minio
storage/minio-data
docs/architecture
docs/setup
```

This document-only phase intentionally does not move directories yet.

For the planned next step, see:

- [phase-2-migration-plan.md](/Users/qinwei/profile/家庭媒体/docs/architecture/phase-2-migration-plan.md)
