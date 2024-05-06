#!/bin/bash

CONFIG_PATH=napcat/config/onebot11_$ACCOUNT.json
# 容器首次启动时执行
if [ ! -f "$CONFIG_PATH" ]; then
    cp -f config.txt $CONFIG_PATH


    if [ "$HTTP_PORT" ]; then
        sed -i "s/HTTP_PORT/$HTTP_PORT/" $CONFIG_PATH
    else
        sed -i "s/HTTP_PORT/3000/" $CONFIG_PATH
    fi

    if [ "$HTTP_URLS" ]; then
        sed -i "s|HTTP_URLS|$HTTP_URLS|" $CONFIG_PATH
    else
        sed -i "s/\"HTTP_URLS\"/\"\"/" $CONFIG_PATH
    fi

    if [ "$WS_PORT" ]; then
        sed -i "s/WS_PORT/$WS_PORT/" $CONFIG_PATH
    else
        sed -i "s/WS_PORT/3001/" $CONFIG_PATH
    fi

    if [ "$HTTP_ENABLE" ]; then
        sed -i "s/HTTP_ENABLE/$HTTP_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/HTTP_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$HTTP_POST_ENABLE" ]; then
        sed -i "s/HTTP_POST_ENABLE/$HTTP_POST_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/HTTP_POST_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$WS_ENABLE" ]; then
        sed -i "s/WS_ENABLE/$WS_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/WS_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$WSR_ENABLE" ]; then
        sed -i "s/WSR_ENABLE/$WSR_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/WSR_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$WS_URLS" ]; then
        sed -i "s#WS_URLS#$WS_URLS#" $CONFIG_PATH
    else
        sed -i "s/\"WS_URLS\"/\"\"/" $CONFIG_PATH
    fi

    if [ "$HEART" ]; then
        sed -i "s/HEART/$HEART/" $CONFIG_PATH
    else
        sed -i "s/HEART/60000/" $CONFIG_PATH
    fi

    if [ "$TOKEN" ]; then
        sed -i "s|TOKEN|$TOKEN|" $CONFIG_PATH
    else
        sed -i "s/\"TOKEN\"/\"\"/" $CONFIG_PATH
    fi

    if [ "$F2U_ENABLE" ]; then
        sed -i "s/F2U_ENABLE/$F2U_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/F2U_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$DEBUG_ENABLE" ]; then
        sed -i "s/DEBUG_ENABLE/$DEBUG_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/DEBUG_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$LOG_ENABLE" ]; then
        sed -i "s/LOG_ENABLE/$LOG_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/LOG_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$RSM_ENABLE" ]; then
        sed -i "s/RSM_ENABLE/$RSM_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/RSM_ENABLE/false/" $CONFIG_PATH
    fi

    if [ "$MESSAGE_POST_FORMAT" ]; then
        sed -i "s/MESSAGE_POST_FORMAT/$MESSAGE_POST_FORMAT/" $CONFIG_PATH
    else
        sed -i "s/MESSAGE_POST_FORMAT/array/" $CONFIG_PATH
    fi

    if [ "$HTTP_HOST" ]; then
        sed -i "s/HTTP_HOST/$HTTP_HOST/" $CONFIG_PATH
    else
        sed -i "s/HTTP_HOST//" $CONFIG_PATH
    fi

    if [ "$WS_HOST" ]; then
        sed -i "s/WS_HOST/$WS_HOST/" $CONFIG_PATH
    else
        sed -i "s/WS_HOST//" $CONFIG_PATH
    fi

    if [ "$HTTP_HEART_ENABLE" ]; then
        sed -i "s/HTTP_HEART_ENABLE/$HTTP_HEART_ENABLE/" $CONFIG_PATH
    else
        sed -i "s/HTTP_HEART_ENABLE/false/" $CONFIG_PATH
    fi
    
    if [ "$MUSIC_SIGN_URL" ]; then
        sed -i "s/MUSIC_SIGN_URL/$MUSIC_SIGN_URL/" $CONFIG_PATH
    else
        sed -i "s/MUSIC_SIGN_URL//" $CONFIG_PATH
    fi
fi

export FFMPEG_PATH=/usr/bin/ffmpeg
cd ./napcat
./napcat.sh -q $ACCOUNT
