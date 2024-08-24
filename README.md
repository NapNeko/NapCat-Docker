# NapCat-Docker

[DockerHub](https://hub.docker.com/r/mlikiowa/napcat-docker)

## Support Platform/Arch
- [x] Linux/Amd64
- [x] Linux/Arm64

## 配置

容器通过环境变量来配置，环境变量名称可以查看 [entrypoint](./entrypoint.sh)👈

具体参数可参考[官方文档](https://napneko.github.io/zh-CN/guide/getting-started)

# 启动容器

## 正向 WS

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
[docker compose 正向 WS](./docker-compose/ws)


## 反向 WS
<details>
<summary>点我查看命令👈</summary>

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WSR_ENABLE=true \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
-e WS_URLS='["ws://192.168.3.8:5140/onebot"]' \
--name napcat \
--restart=always \
mlikiowa/napcat-docker:latest
```

[docker compose 反向 WS](./docker-compose/we-reverse)


</details>

## HTTP
<details>
<summary>点我查看命令👈</summary>

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e HTTP_ENABLE=true \
-e HTTP_POST_ENABLE=true \
-e NAPCAT_GID=$(id -g) \
-e NAPCAT_UID=$(id -u) \
-e HTTP_URLS='["http://192.168.3.8:5140/onebot"]' \
-p 3000:3000 \
-p 6099:6099 \
--name napcat \
--restart=always \
mlikiowa/napcat-docker:latest
```

[docker compose HTTP POST](./docker-compose/http)

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