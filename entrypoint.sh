#!/bin/bash

update_napcatfile() {
    # 定义下载链接
    URL1="https://github.moeyy.xyz/https://github.com/NapNeko/NapCatQQ/releases/latest/download/NapCat.Shell.zip"
    URL2="https://github.com/NapNeko/NapCatQQ/releases/latest/download/NapCat.Shell.zip"

    # 检查NapCat.Shell.zip是否存在，不存在则下载
    if [ ! -f "NapCat.Shell.zip" ]; then
        echo "NapCat.Shell.zip 文件不存在，开始下载..."

        # 尝试第一个下载链接
        if curl -L -O "$URL1"; then
            echo "文件下载成功，创建备份..."
            cp -f "NapCat.Shell.zip" "NapCat.Shell_old.zip"
        else
            echo "第一个下载链接失败，尝试第二个链接..."
            # 尝试第二个下载链接
            if curl -L -O "$URL2"; then
                echo "文件下载成功，创建备份..."
                cp -f "NapCat.Shell.zip" "NapCat.Shell_old.zip"
            else
                echo "两个下载链接都失败了，尝试使用备份文件。"

                # 如果备份文件存在，则克隆为NapCat.Shell.zip
                if [ -f "NapCat.Shell_old.zip" ]; then
                    echo "使用备份文件恢复..."
                    cp -f "NapCat.Shell_old.zip" "NapCat.Shell.zip"
                else
                    echo "备份文件不存在，请手动下载。"
                    exit 1
                fi
            fi
        fi
    else
        echo "已存在文件，创建备份..."
        cp -f "NapCat.Shell.zip" "NapCat.Shell_old.zip"
    fi
}


# 安装 napcat
if [ ! -f "napcat/napcat.mjs" ]; then
    update_napcatfile
    unzip -q NapCat.Shell.zip -d ./NapCat.Shell
    if [ -f "napcat/config/napcat.json" ]; then
        echo "发现napcat/config/napcat.json，排除NapCat.Shell/config文件夹。"
        #rsync -av --exclude='config/' NapCat.Shell/ napcat/
        find NapCat.Shell -path NapCat.Shell/config -prune -o -exec cp -r {} napcat/ \;
    else
        echo "未发现napcat/config/napcat.json，全部内容将被复制。"
        cp -rf NapCat.Shell/* napcat/
    fi
    rm -rf ./NapCat.Shell
    rm -rf ./NapCat.Shell.zip
fi

if [ ! -f "napcat/config/napcat.json" ]; then
    unzip -q NapCat.Shell_old.zip -d ./NapCat.Shell_old
    cp -rf NapCat.Shell_old/config/* napcat/config/
    rm -rf ./NapCat.Shell_old
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

if [ -n "${MODE}" ]; then
    cp /app/templates/$MODE.json /app/napcat/config/onebot11.json
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
if [ -n "${ACCOUNT}" ]; then
    gosu napcat /opt/QQ/qq --no-sandbox -q $ACCOUNT
else
    gosu napcat /opt/QQ/qq --no-sandbox
fi
