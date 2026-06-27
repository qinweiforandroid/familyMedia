# Troubleshooting

## Purpose

This document records common local runtime issues for the family media workspace and how to resolve them quickly.

Use this together with:

- [README.md](/Users/qinwei/profile/家庭媒体/README.md)
- [doctor.sh](/Users/qinwei/profile/家庭媒体/scripts/doctor.sh)

## First Step

Before debugging anything else, run:

```bash
./scripts/doctor.sh
```

This will tell you whether:

- required directories exist
- system `node` / `npm`, Gradle wrapper, and MinIO binary are available
- Java and MySQL tools can be detected
- ports are listening
- pid files are alive or stale
- log files exist

## Short Recovery Flow

If the local environment is currently broken, use this shortest recovery path first:

1. Verify system `node` / `npm`:

```bash
node -v
npm -v
```

2. Fix MinIO provenance if needed:

```bash
xattr -d com.apple.provenance ./infra/minio/minio
```

3. Remove stale pid files:

```bash
rm -f ./.run/pids/minio.pid ./.run/pids/backend.pid ./.run/pids/frontend.pid
```

4. Start services in order:

```bash
./scripts/start-minio.sh
./scripts/start-backend.sh
./scripts/start-admin-web.sh
```

5. Re-run health checks:

```bash
./scripts/doctor.sh
```

## Common Problems

### MinIO does not start on macOS

Typical symptoms:

- `doctor.sh` shows:
  `MinIO binary still has com.apple.provenance attribute`
- `start-minio.sh` does not bring up port `9000`

Cause:

- macOS gatekeeper metadata can block or interfere with a moved MinIO binary.

Fix:

```bash
xattr -d com.apple.provenance ./infra/minio/minio
```

Then retry:

```bash
./scripts/start-minio.sh
```

### `doctor.sh` shows a pid file but the service is not running

Typical symptoms:

- `doctor.sh` shows:
  `pid file exists but process is not running`

Cause:

- a previous run exited unexpectedly and left a stale pid file

Fix:

1. Remove the stale pid file from `.run/pids/`
2. Start the service again with the matching `start-*.sh` script

Example:

```bash
rm -f ./.run/pids/minio.pid
./scripts/start-minio.sh
```

### MySQL commands are not found

Typical symptoms:

- `doctor.sh` shows:
  `mysqladmin not found in PATH`
- `start-stack.sh` fails because `mysql` or `mysqld_safe` cannot be found

Cause:

- MySQL client or server tools are not installed, or they are not in `PATH`

Fix:

1. Install MySQL tools
2. Make sure `mysql`, `mysqladmin`, and `mysqld_safe` are available in `PATH`
3. Retry:

```bash
./scripts/doctor.sh
```

### Java 17 cannot be detected

Typical symptoms:

- `doctor.sh` shows:
  `Java 17 home could not be detected`
- `start-backend.sh` fails early

Cause:

- Java 17 is not installed, or `/usr/libexec/java_home -v 17` cannot resolve it

Fix:

1. Install Java 17
2. Verify:

```bash
/usr/libexec/java_home -v 17
```

3. Retry:

```bash
./scripts/start-backend.sh
```

### System `node` / `npm` exists but cannot execute

Typical symptoms:

- `doctor.sh` shows:
  `System node exists but cannot execute cleanly`
  or
  `System npm exists but cannot execute cleanly`

Cause:

- the system Node.js installation is broken or linked against missing libraries

Fix:

1. Verify directly:

```bash
node -v
npm -v
```

2. Repair or upgrade the system Node.js installation

3. Retry:

```bash
./scripts/doctor.sh
```

### Backend starts but port `8080` never comes up

Typical symptoms:

- `start-backend.sh` hangs and then says backend did not become ready
- `doctor.sh` shows backend not listening on `8080`

Common checks:

1. Read the backend log:

```bash
./scripts/logs-backend.sh
```

2. Verify Java 17 detection:

```bash
./scripts/doctor.sh
```

3. Run the backend manually from its module:

```bash
cd apps/backend
./gradlew bootRun
```

### Admin web starts but port `5173` never comes up

Typical symptoms:

- `start-admin-web.sh` does not finish successfully
- `doctor.sh` shows admin web not listening on `5173`

Common checks:

1. Read the frontend log:

```bash
./scripts/logs-admin-web.sh
```

2. Verify system Node.js and npm detection:

```bash
./scripts/doctor.sh
```

3. Run the build once to verify dependencies:

```bash
./scripts/build-admin-web.sh
```

### `build-admin-web.sh` fails immediately

Typical symptoms:

- frontend build exits before Vite runs

Common checks:

1. Verify system `node` and `npm` are available and healthy:

```bash
./scripts/doctor.sh
```

2. If `node -v` or `npm -v` fails, repair or upgrade your system Node.js first

3. Ensure `apps/admin-web/package.json` and `apps/admin-web/node_modules` are present

4. Retry:

```bash
./scripts/build-admin-web.sh
```

### MinIO, backend, or admin web start fine in your terminal but not inside an AI tool session

Typical symptoms:

- services do not stay alive when started from a restricted tool environment
- logs may be empty
- ports remain closed even though the command appeared to start

Cause:

- some execution environments restrict background service management

Fix:

- prefer running the start scripts in your own local terminal
- use `doctor.sh` afterward to verify real runtime state

## Recommended Recovery Order

If the local environment is in a messy state, recover in this order:

1. Run `./scripts/doctor.sh`
2. Stop anything that is partially running:
   `./scripts/stop-stack.sh`
3. Remove stale pid files in `.run/pids/` if needed
4. Fix MinIO provenance if shown
5. Start in this order:
   `./scripts/start-minio.sh`
   `./scripts/start-backend.sh`
   `./scripts/start-admin-web.sh`
6. Re-run `./scripts/doctor.sh`

## Useful Scripts

- `./scripts/doctor.sh`
- `./scripts/start-minio.sh`
- `./scripts/start-backend.sh`
- `./scripts/start-admin-web.sh`
- `./scripts/status-stack.sh`
- `./scripts/status-apps.sh`
- `./scripts/logs-backend.sh`
- `./scripts/logs-admin-web.sh`
- `./scripts/stop-stack.sh`
