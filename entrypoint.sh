#!/bin/bash

chech_quotes(){
    local input="$1"
    if [ "${input:0:1}" != '"' ] ; then
        if [ "${input:0:1}" != '[' ] ; then
            input="[\"$input\"]"
        fi
    else
        input="[$input]"
    fi
    echo $input
}

# 安装 napcat
if [ ! -f "napcat/napcat.mjs" ]; then
    unzip -q NapCat.Shell.zip -d ./NapCat.Shell
    cp -rf NapCat.Shell/* napcat/
    rm -rf ./NapCat.Shell
fi
if [ ! -f "napcat/config/napcat.json" ]; then
    unzip -q NapCat.Shell.zip -d ./NapCat.Shell
    cp -rf NapCat.Shell/config/* napcat/config/
    rm -rf ./NapCat.Shell
fi

CONFIG_PATH=napcat/config/onebot11_$ACCOUNT.json
# 容器首次启动时执行
if [ ! -f "$CONFIG_PATH" ]; then
    if [ "$WEBUI_TOKEN" ]; then
        echo "{\"port\": 6099,\"token\": \"$WEBUI_TOKEN\",\"loginRate\": 3}" > napcat/config/webui.json
    fi
    : ${WEBUI_TOKEN:=''}
    : ${HTTP_PORT:=3000}
    : ${HTTP_URLS:='[]'}
    : ${WS_PORT:=3001}
    : ${HTTP_ENABLE:='false'}
    : ${HTTP_POST_ENABLE:='false'}
    : ${WS_ENABLE:='false'}
    : ${WSR_ENABLE:='false'}
    : ${WS_URLS:='[]'}
    : ${HEART_INTERVAL:=60000}
    : ${TOKEN:=''}
    : ${F2U_ENABLE:='false'}
    : ${DEBUG_ENABLE:='false'}
    : ${LOG_ENABLE:='false'}
    : ${RSM_ENABLE:='false'}
    : ${MESSAGE_POST_FORMAT:='array'}
    : ${HTTP_HOST:=''}
    : ${WS_HOST:=''}
    : ${HTTP_HEART_ENABLE:='false'}
    : ${MUSIC_SIGN_URL:=''}
    : ${HTTP_SECRET:=''}
    : ${NAPCAT_GID:=1001}
    : ${NAPCAT_UID:=911}
    HTTP_URLS=$(chech_quotes $HTTP_URLS)
    WS_URLS=$(chech_quotes $WS_URLS)
cat <<EOF > $CONFIG_PATH
{
    "http": {
      "enable": ${HTTP_ENABLE},
      "host": "$HTTP_HOST",
      "port": ${HTTP_PORT},
      "secret": "$HTTP_SECRET",
      "enableHeart": ${HTTP_HEART_ENABLE},
      "enablePost": ${HTTP_POST_ENABLE},
      "postUrls": $HTTP_URLS
    },
    "ws": {
      "enable": ${WS_ENABLE},
      "host": "${WS_HOST}",
      "port": ${WS_PORT}
    },
    "reverseWs": {
      "enable": ${WSR_ENABLE},
      "urls": $WS_URLS
    },
    "GroupLocalTime":{
      "Record": false,
      "RecordList": []
    },
    "debug": ${DEBUG_ENABLE},
    "heartInterval": ${HEART_INTERVAL},
    "messagePostFormat": "$MESSAGE_POST_FORMAT",
    "enableLocalFile2Url": ${F2U_ENABLE},
    "musicSignUrl": "$MUSIC_SIGN_URL",
    "reportSelfMessage": ${RSM_ENABLE},
    "token": "$TOKEN"
}
EOF
    if [ "$(arch)" = "x86_64" ]; then
        jq '.packetServer = "127.0.0.1:8086"' napcat/config/napcat.json > napcat/config/napcat._json && mv napcat/config/napcat._json napcat/config/napcat.json
        cp -f napcat/config/napcat.json napcat/config/napcat_$ACCOUNT.json
    fi
fi
rm -rf "/tmp/.X1-lock"

usermod -o -u ${NAPCAT_UID} napcat
groupmod -o -g ${NAPCAT_GID} napcat
usermod -g ${NAPCAT_GID} napcat
chown -R ${NAPCAT_UID}:${NAPCAT_GID} /app

gosu napcat Xvfb :1 -screen 0 1080x760x16 +extension GLX +render > /dev/null 2>&1 &
sleep 2
# 方便调试, 或许应该重定向到/dev/null?
if [ "$(arch)" = "x86_64" ]; then
    cd /app/napcat.packet/
    /app/napcat.packet/napcat.packet.linux 2>&1 &
    sleep 2
fi
export FFMPEG_PATH=/usr/bin/ffmpeg
export DISPLAY=:1
cd /app/napcat
gosu napcat /opt/QQ/qq --no-sandbox -q $ACCOUNT
