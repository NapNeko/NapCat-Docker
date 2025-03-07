# NapCat-Docker

[DockerHub](https://hub.docker.com/r/mlikiowa/napcat-docker)

## Support Platform/Arch
- [x] Linux/Amd64
- [x] Linux/Arm64

# 启动容器
### 获取日志/查看Token
`docker logs 容器名`
 
示例 `docker logs napcat`
默认登录Token `napcat`
### 命令行运行

```shell
docker run -d \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
-p 3000:3000 \
-p 3001:3001 \
-p 6099:6099 \
--name napcat \
--restart=always \
mlikiowa/napcat-docker:latest
```

### docker-compose 运行

创建 `docker-compose.yml` 文件
```yaml
# docker-compose.yml
version: "3"
services:
    napcat:
        environment:
            - NAPCAT_UID=${NAPCAT_UID}
            - NAPCAT_GID=${NAPCAT_GID}
        ports:
            - 3000:3000
            - 3001:3001
            - 6099:6099
        container_name: napcat
        network_mode: bridge
        restart: always
        image: mlikiowa/napcat-docker:latest
```

使用 `NAPCAT_UID=$(id -u) NAPCAT_GID=$(id -g) docker-compose up -d` 运行到后台


# 固化路径，方便下次直接快速登录

QQ 持久化数据路径：/app/.config/QQ

NapCat 配置文件路径: /app/napcat/config

# 登录

登录 WebUI 地址：http://<宿主机ip>:6099/webui

# Tips
关于 NAPCAT_UID 与 NAPCAT_GID 环境变量

[前往了解](https://containerization-automation.readthedocs.io/zh-cn/latest/docker/storage/[gosu]%E7%BB%91%E5%AE%9A%E6%8C%82%E8%BD%BD%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5/)


# 一键模板化配置
[AstrBot Compose模板](./compose/astrbot.yml)
[Koishi Compose模板](./compose/koishi.yml)

> 欢迎Pr.此方案快速填充填充NapCat侧配置,你只需要配置应用侧,注意当你不需要WebUi或者处于公网环境,请注意6099端口和WebUi默认密码。
