# 家庭媒体工作区

这是一个本地开发工作区，包含家庭媒体系统的后端、管理后台、运行脚本和本地对象存储资源。

## 先看哪里

- 仓库导航: [AGENTS.md](/Users/qinwei/profile/家庭媒体/AGENTS.md)
- 结构地图: [docs/architecture/repo-map.md](/Users/qinwei/profile/家庭媒体/docs/architecture/repo-map.md)
- AI 阅读指南: [docs/ai/repo-guide.md](/Users/qinwei/profile/家庭媒体/docs/ai/repo-guide.md)
- 第二阶段迁移方案: [docs/architecture/phase-2-migration-plan.md](/Users/qinwei/profile/家庭媒体/docs/architecture/phase-2-migration-plan.md)
- 排障指南: [docs/setup/troubleshooting.md](/Users/qinwei/profile/家庭媒体/docs/setup/troubleshooting.md)
- 外部仓库清单: [workspace.repos.json](/Users/qinwei/profile/家庭媒体/workspace.repos.json)

## 顶层目录

- `apps/backend`: Java Spring Boot 后端
- `apps/admin-web`: Vue 3 管理后台
- `apps/android`: Android 工作区
- `scripts`: 本地启动和运维脚本
- `infra/minio`: 本地 MinIO 二进制和辅助文件
- `storage/minio-data`: 本地 MinIO 数据目录
- 系统 `node` / `npm`: 前端脚本依赖系统 Node.js 环境

## 外部仓库模式

`家庭媒体` 现在适合被当成一个工作区仓库使用：

- 保留脚本、文档、运行时、基础设施配置
- `apps/backend` 和 `apps/admin-web` 作为独立 git 仓库管理
- 仓库地址和默认开发分支记录在 `workspace.repos.json`

## Git 使用约定

当前工作区使用三层 Git 边界：

- 根仓库 `家庭媒体`: 管理工作区文档、脚本、`workspace.repos.json` 和根级说明文件
- 子仓库 `apps/backend`: 管理后端源码、后端配置、后端文档和 HTTP 示例
- 子仓库 `apps/admin-web`: 管理前端源码、前端依赖和前端模块文档

日常使用建议：

- 修改 `scripts/`、`docs/`、`README.md`、`AGENTS.md` 或 `workspace.repos.json` 时，在根仓库提交
- 修改后端代码或后端模块文档时，在 `apps/backend` 仓库提交
- 修改前端代码或前端模块文档时，在 `apps/admin-web` 仓库提交

建议先确认自己当前所在仓库，再执行 `git status`、`git add`、`git commit` 和 `git push`。

根仓库不会跟踪以下内容：

- `storage/`
- `.run/`
- `runtime/`
- `infra/minio` 下的本地二进制
- `apps/backend` 和 `apps/admin-web` 的仓库内容

常用检查命令：

```bash
git status
git -C apps/backend status
git -C apps/admin-web status
```

首次拉取外部仓库：

```bash
./scripts/bootstrap-workspace.sh
```

按配置分支更新外部仓库：

```bash
./scripts/update-workspace.sh
```

## 常用脚本

启动整套环境：

```bash
./scripts/start-stack.sh
```

单独启动 MinIO：

```bash
./scripts/start-minio.sh
```

单独启动后端：

```bash
./scripts/start-backend.sh
```

单独启动管理后台前端：

```bash
./scripts/start-admin-web.sh
```

查看运行状态：

```bash
./scripts/status-stack.sh
```

只看应用状态：

```bash
./scripts/status-apps.sh
```

执行环境自检：

```bash
./scripts/doctor.sh
```

查看后端日志：

```bash
./scripts/logs-backend.sh
```

查看管理后台前端日志：

```bash
./scripts/logs-admin-web.sh
```

执行后端测试：

```bash
./scripts/test-backend.sh
```

构建管理后台前端：

```bash
./scripts/build-admin-web.sh
```

停止整套环境：

```bash
./scripts/stop-stack.sh
```

重启整套环境：

```bash
./scripts/restart-stack.sh
```

单独停止 MinIO：

```bash
./scripts/stop-minio.sh
```

单独停止后端：

```bash
./scripts/stop-backend.sh
```

单独停止管理后台前端：

```bash
./scripts/stop-admin-web.sh
```

## 本地服务端口

- MySQL: `127.0.0.1:3306`
- Backend: `http://127.0.0.1:8080/code`
- Frontend: `http://127.0.0.1:5173/`
- MinIO API: `http://127.0.0.1:9000`
- MinIO Console: `http://127.0.0.1:9001`

## 关键路径

- 后端源码: `apps/backend/src/main`
- 前端源码: `apps/admin-web/src`
- 后端配置: `apps/backend/src/main/resources`
- SQL 文档: `apps/backend/doc/sql`
- 方案文档: `apps/backend/doc/design`
- 历史记录: `apps/backend/doc/history`
- Node 环境: 系统 `node` / `npm`
- MinIO 二进制目录: `infra/minio`
- MinIO 数据目录: `storage/minio-data`
- 运行日志目录: `.run/logs`

## 当前阶段建议

如果目标是让 AI 更好理解这个项目，优先使用这三个文件建立上下文：

1. `AGENTS.md`
2. `docs/architecture/repo-map.md`
3. `README.md`

这一阶段只补充文档和仓库地图，不移动业务目录，降低整理成本和回归风险。

如果要继续推进目录重构，先看：

- [docs/architecture/phase-2-migration-plan.md](/Users/qinwei/profile/家庭媒体/docs/architecture/phase-2-migration-plan.md)

## 建议忽略目录

以下目录通常不适合作为功能分析入口：

- `.run`
- `storage/minio-data`
- `apps/backend/build`
- `apps/backend/.gradle`
- `apps/backend/log`
- `apps/admin-web/node_modules`
