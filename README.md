# NapCat-Docker

[Docker Hub](https://hub.docker.com/r/mlikiowa/napcat-docker) · Linux amd64 / arm64

## 启动

保存为 `compose.yaml`，修改 `WEBUI_TOKEN`：

```yaml
services:
  napcat:
    image: mlikiowa/napcat-docker:latest
    restart: unless-stopped
    environment:
      MODE: ws
      WEBUI_TOKEN: replace-with-your-own-token
    ports:
      - "127.0.0.1:6099:6099"
      - "127.0.0.1:3001:3001"
    volumes:
      - ./data/qq:/app/.config/QQ
      - ./data/config:/app/napcat/config
      - ./data/plugins:/app/napcat/plugins
```

```bash
docker compose up -d
docker compose logs -f napcat
```

打开 `http://127.0.0.1:6099/webui` 登录。远程访问需调整端口绑定地址或使用 SSH 转发。

## 配置与更新

- `MODE=ws` 启用正向 WebSocket；反向连接使用 `reverse_ws` / `reverse_http`，并设置 `ONEBOT_URL`。
- `WEBUI_TOKEN`、`MODE` 仅初始化缺失的配置。已有部署在 WebUI 中修改。
- `NAPCAT_UID`、`NAPCAT_GID` 指定运行用户，挂载目录需允许该用户读写；群晖还需设置共享目录 ACL。
- 更新执行 `docker compose pull && docker compose up -d`，保留三个数据目录。固定版本时将 `latest` 换成发布标签。
- 镜像拉取的代理需配置在 Docker daemon 中。
- 需要调试 core dump 时设置 `NAPCAT_ENABLE_COREDUMP=1`。

维护者构建发布镜像时应使用 `docker buildx build --pull --no-cache ...`，确保读取当前基础镜像和 Ubuntu 安全仓库。最终镜像会刷新系统包、补齐 Linux QQ 声明的 `xdg-utils` 依赖，并移除运行时不需要的内核开发头；此步骤不升级 QQ 内嵌的 Electron/Node，也不改变账号与配置挂载目录。

构建后可运行 `bash tests/runtime-smoke.sh <image>`，在不联网、不挂载账号目录的临时容器中检查包状态、QQ 共享库和 WebUI 启动。脚本会删除自己创建的临时容器；此检查不包含 QQ 登录、消息收发或插件验收。

## 机器人框架模板

[AstrBot](./compose/astrbot.yml) · [Koishi](./compose/koishi-compose.yml) · [qq-ai-bot](./compose/qq-ai-bot.yml) · [WebSocket](./compose/ws.yml)
