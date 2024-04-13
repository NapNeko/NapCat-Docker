# NapCat-Docker

[DockerHub](https://hub.docker.com/r/mlikiowa/napcat-docker)

## Support Platform/Arch
- [x] Linux/Amd64
- [x] Linux/Arm64


# 启动容器

## 正向 WS

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WS_ENABLE=true \
-p 3001:3001 \
--name napcat \
mlikiowa/napcat-docker:latest
```

```yaml
# docker compose 正向 WS
version: "3"
services:
    napcat:
        environment:
            - ACCOUNT=<机器人qq>
            - WS_ENABLE=true
        ports:
            - 3001:3001
        container_name: napcat
        network_mode: bridge
        image: mlikiowa/napcat-docker:latest
```

## 反向 WS

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WSR_ENABLE=true \
-e WS_URLS="ws://192.168.3.8:5140/onebot" \
--name napcat \
mlikiowa/napcat-docker:latest
```

```yaml
# docker compose 反向 WS
version: "3"
services:
    napcat:
        environment:
            - ACCOUNT=<机器人qq>
            - WSR_ENABLE=true
            - WS_URLS="ws://192.168.3.8:5140/onebot"
        container_name: napcat
        network_mode: bridge
        image: mlikiowa/napcat-docker:latest
```
## HTTP
```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e HTTP_ENABLE=true \
-e HTTP_POST_ENABLE=true \
-e HTTP_URLS="http://192.168.3.8:5140/onebot" \
-p 3000:3000 \
--name napcat \
mlikiowa/napcat-docker:latest
```

```yaml
# docker compose HTTP POST
version: "3"
services:
    napcat:
        environment:
            - ACCOUNT=<机器人qq>
            - HTTP_ENABLE=true
            - HTTP_POST_ENABLE=true
            - HTTP_URLS="http://192.168.3.8:5140/onebot"
        ports:
            - 3000:3000
        container_name: napcat
        network_mode: bridge
        image: mlikiowa/napcat-docker:latest
```
# 登录

```shell
docker logs napcat
```
