# NapCat-Docker

[DockerHub](https://hub.docker.com/r/mlikiowa/napcat-docker)

## Support Platform/Arch
- [x] Linux/Amd64
- [x] Linux/Arm64

## 配置

容器通过环境变量来配置，环境变量名称可以查看 [entrypoint](./entrypoint.sh)👈

具体参数可参考[官方文档](https://napneko.github.io/zh-CN/guide/getting-started)

# 启动容器

```
git clone https://github.com/Fahaxikiii/NapCat-Docker.git
cd NapCat-Docker
docker-compose up -d
```

## 正向 WS

### 命令行运行

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WS_ENABLE=true \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
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
            - ACCOUNT=<机器人qq>
            - WS_ENABLE=true
            - NAPCAT_UID=${NAPCAT_UID}
            - NAPCAT_GID=${NAPCAT_GID}
        ports:
            - 3001:3001
            - 6099:6099
        container_name: napcat
        network_mode: bridge
        restart: always
        image: mlikiowa/napcat-docker:latest
```

使用 `NAPCAT_UID=$(id -u); NAPCAT_GID=$(id -g); docker-compose up -d` 运行到后台

## 反向 WS
<details>
<summary>点我查看命令👈</summary>

### 命令行运行

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WSR_ENABLE=true \
-e WS_URLS='["ws://192.168.3.8:5140/onebot"]' \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
--name napcat \
--restart=always \
mlikiowa/napcat-docker:latest
```
### docker-compose 运行

按照 [正向 WS](#docker-compose-运行) 中的方式创建 `.env` 文件，然后创建 `docker-compose.yml` 文件
```yaml
# docker-compose.yml
version: "3"
services:
    napcat:
        environment:
            - ACCOUNT=<机器人qq>
            - WSR_ENABLE=true
            - WS_URLS=["ws://192.168.3.8:5140/onebot"]
            - NAPCAT_UID=${NAPCAT_UID}
            - NAPCAT_GID=${NAPCAT_GID}
        container_name: napcat
        network_mode: bridge
        ports:
           - 6099:6099
        restart: always
        image: mlikiowa/napcat-docker:latest
```

使用 `NAPCAT_UID=$(id -u); NAPCAT_GID=$(id -g); docker-compose up -d` 运行到后台
</details>

## HTTP
<details>
<summary>点我查看命令👈</summary>

### 命令行运行

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e HTTP_ENABLE=true \
-e HTTP_POST_ENABLE=true \
-e HTTP_URLS='["http://192.168.3.8:5140/onebot"]' \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
-p 3000:3000 \
-p 6099:6099 \
--name napcat \
--restart=always \
mlikiowa/napcat-docker:latest
```

### docker-compose 运行

按照 [正向 WS](#docker-compose-运行) 中的方式创建 `.env` 文件，然后创建 `docker-compose.yml` 文件
```yaml
# docker-compose.yml
version: "3"
services:
    napcat:
        environment:
            - ACCOUNT=<机器人qq>
            - HTTP_ENABLE=true
            - HTTP_POST_ENABLE=true
            - HTTP_URLS=["http://192.168.3.8:5140/onebot"]
            - NAPCAT_UID=${NAPCAT_UID}
            - NAPCAT_GID=${NAPCAT_GID}
        ports:
            - 3000:3000
            - 6099:6099
        container_name: napcat
        network_mode: bridge
        restart: always
        image: mlikiowa/napcat-docker:latest
```

使用 `NAPCAT_UID=$(id -u); NAPCAT_GID=$(id -g); docker-compose up -d` 运行到后台
</details>

# 固化路径，方便下次直接快速登录

QQ 持久化数据路径：/app/.config/QQ

NapCat 配置文件路径: /app/napcat/config

注意：如果是重新创建的容器，需要固定 Mac 地址

# 登录

```shell
docker logs napcat
```

# Tips

- 若 Docker 镜像拉取失败，可以使用 [Docker 镜像加速服务](https://github.com/dqzboy/Docker-Proxy) 
