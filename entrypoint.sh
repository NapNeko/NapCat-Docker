#!/bin/bash

sed -i "s|COMMAND|bash /root/napcat.sh -q $ACCOUNT|" /etc/supervisord.conf

CONFIG_PATH=/root/config/onebot11_$ACCOUNT.json
# 容器首次启动时执行
if [ ! -f "$CONFIG_PATH" ]; then
    cp -f /root/config.txt $CONFIG_PATH


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

    if [ "WS_URLS" ]; then
        sed -i "s/WS_URLS/$WS_URLS/" $CONFIG_PATH
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
fi

bash /root/napcat.sh -q $ACCOUNT &
exec supervisord