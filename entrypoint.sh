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

CONFIG_PATH=napcat/config/onebot11_$ACCOUNT.json
# 容器首次启动时执行
if [ ! -f "$CONFIG_PATH" ]; then
    # 安装 napcat
    rarch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/)
    unzip -q NapCat.linux.${rarch}.zip
    mv NapCat.linux.${rarch}/config/* napcat/config/ && rmdir NapCat.linux.${rarch}/config
    mv NapCat.linux.${rarch}/* napcat/
    chmod +x napcat/napcat.sh
    
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
    HTTP_URLS=$(chech_quotes $HTTP_URLS)
    WS_URLS=$(chech_quotes $WS_URLS)
cat <<EOF > $CONFIG_PATH
{
    "httpHost": "$HTTP_HOST",
    "enableHttp": ${HTTP_ENABLE},
    "httpPort": ${HTTP_PORT},
    "wsHost": "${WS_HOST}",
    "enableWs": ${WS_ENABLE},
    "wsPort": ${WS_PORT},
    "enableWsReverse": ${WSR_ENABLE},
    "wsReverseUrls": $WS_URLS,
    "enableHttpPost": ${HTTP_POST_ENABLE},
    "httpPostUrls": $HTTP_URLS,
    "enableHttpHeart": ${HTTP_HEART_ENABLE},
    "httpSecret": "$HTTP_SECRET",
    "messagePostFormat": "$MESSAGE_POST_FORMAT",
    "reportSelfMessage": ${RSM_ENABLE},
    "debug": ${DEBUG_ENABLE},
    "enableLocalFile2Url": ${F2U_ENABLE},
    "heartInterval": ${HEART_INTERVAL},
    "token": "$TOKEN",
    "musicSignUrl": "$MUSIC_SIGN_URL"
}
EOF
fi

export FFMPEG_PATH=/usr/bin/ffmpeg
cd ./napcat
./napcat.sh -q $ACCOUNT
