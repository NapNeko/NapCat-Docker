# NapCat-Docker
NapCat-Docker


## 正向 WS

```shell
docker run \
-e ACCOUNT=<机器人qq> \
-d -p 3001:3001 \
-e WS_ENABLE=true \
--name napcat \
mlikiowa/napcat-docker:latest
```


## 反向 WS

```shell
docker run -d \
-e ACCOUNT=<机器人qq> \
-e WSR_ENABLE=true \
-e WS_URLS="http://localhost:5140/onebot"
--name napcat \
mlikiowa/napcat-docker:latest
```


## HTTP
```shell
docker run \
-e ACCOUNT=<机器人qq> \
-d -p 3000:3000 \
-e HTTP_ENABLE=true \
--name napcat \
mlikiowa/napcat-docker:latest
```