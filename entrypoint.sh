#!/bin/bash

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

# 配置 WebUI Token
CONFIG_PATH=/app/napcat/config/webui.json

if [ ! -f "${CONFIG_PATH}" ] && [ -n "${WEBUI_TOKEN}" ]; then
    echo "正在配置 WebUI Token..."
    cat > "${CONFIG_PATH}" << EOF
{
    "host": "0.0.0.0",
    "prefix": "${WEBUI_PREFIX}",
    "port": 6099,
    "token": "${WEBUI_TOKEN}",
    "loginRate": 3
}
EOF
fi

# 删除字符串两端的引号
remove_quotes() {
    local str="$1"
    local first_char="${str:0:1}"
    local last_char="${str: -1}"

    if [[ ($first_char == '"' && $last_char == '"') || ($first_char == "'" && $last_char == "'") ]]; then
        # 两端都是双引号
        if [[ $first_char == '"' ]]; then
            str="${str:1:-1}"
        # 两端都是单引号
        else
            str="${str:1:-1}"
        fi
    fi
    echo "$str"
}

: ${WS_ENABLE:='false'}
: ${WS_PORT:=3001}
: ${RWS_ENABLE:='false'}
: ${RWS_ADDRESS:='ws://127.0.0.1:8080/onebot/v11/ws'}

# 配置 onebot
CONFIG_PATH=/app/napcat/config/onebot11_$ACCOUNT.json

if [ ! -f "${CONFIG_PATH}" ]; then
    cat > "${CONFIG_PATH}" << EOF
{
  "http": {
    "enable": false,
    "host": "",
    "port": 3000,
    "secret": "",
    "enableHeart": false,
    "enablePost": false,
    "postUrls": []
  },
  "ws": {
    "enable": false,
    "host": "",
    "port": 3001
  },
  "reverseWs": {
    "enable": false,
    "urls": []
  },
  "GroupLocalTime": {
    "Record": false,
    "RecordList": []
  },
  "debug": false,
  "heartInterval": 30000,
  "messagePostFormat": "array",
  "enableLocalFile2Url": true,
  "musicSignUrl": "",
  "reportSelfMessage": false,
  "token": "",
  "network": {
    "httpServers": [],
    "httpSseServers": [],
    "httpClients": [],
    "websocketServers": [
      {
        "enable": $(remove_quotes $WS_ENABLE),
        "name": "ws",
        "host": "0.0.0.0",
        "port": $(remove_quotes $WS_PORT),
        "reportSelfMessage": false,
        "enableForcePushEvent": true,
        "messagePostFormat": "array",
        "token": "",
        "debug": false,
        "heartInterval": 30000
      }
    ],
    "websocketClients": [
      {
        "enable": $(remove_quotes $RWS_ENABLE),
        "name": "rws",
        "url": "$(remove_quotes $RWS_ADDRESS)",
        "reportSelfMessage": false,
        "messagePostFormat": "array",
        "token": "",
        "debug": false,
        "heartInterval": 30000,
        "reconnectInterval": 30000
      }
    ],
    "plugins": []
  },
  "parseMultMsg": false
}
EOF
fi

rm -rf "/tmp/.X1-lock"

: ${NAPCAT_GID:=0}
: ${NAPCAT_UID:=0}
usermod -o -u ${NAPCAT_UID} napcat
groupmod -o -g ${NAPCAT_GID} napcat
usermod -g ${NAPCAT_GID} napcat
chown -R ${NAPCAT_UID}:${NAPCAT_GID} /app

gosu napcat Xvfb :1 -screen 0 1080x760x16 +extension GLX +render > /dev/null 2>&1 &
sleep 2

export FFMPEG_PATH=/usr/bin/ffmpeg
export DISPLAY=:1
cd /app/napcat
gosu napcat /opt/QQ/qq --no-sandbox -q $ACCOUNT
