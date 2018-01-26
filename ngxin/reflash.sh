#! /bin/bash

if [ $# -lt 4 ]; then
    echo $0 parameters err
    exit 0
fi

NAME=$1
NUM=$2
PORT=$3
NAMESPACE=$4

ADDRESS=$NAME-$NUM.$NAME.$NAMESPACE.svc.cluster.local
CONFIG_DIR=/etc/nginx/conf.d/stream
IP_TEMP_DIR=/temp

IP_TEMP_FILE="$IP_TEMP_DIR/ip-$NUM-$PORT"
PROXY_CONFIG_FILE="$CONFIG_DIR/config-$NUM-$PORT.conf"

TMPSTR=`ping ${ADDRESS} -s 1 -c 1 | grep ${ADDRESS} | head -n 1`
CURRENT_IP=`echo ${TMPSTR} | cut -d'(' -f 2 | cut -d')' -f1`

if [ ! -f "$IP_TEMP_FILE" ]; then
    echo "" > "$IP_TEMP_FILE"
fi

if [ ! -n "$CURRENT_IP" ];then
    echo "nil ip address"
    echo "" > "$IP_TEMP_FILE"
    if [ -f "$PROXY_CONFIG_FILE" ]; then
        rm -f $PROXY_CONFIG_FILE
        nginx -s reload
    fi
    exit 0
fi

if [ ! -f "$PROXY_CONFIG_FILE" ]; then
    let listen_port=$PORT+$NUM
    echo "server {"                           > "$PROXY_CONFIG_FILE"
    echo "    listen $listen_port;"          >> "$PROXY_CONFIG_FILE"
    echo "    proxy_connect_timeout 1s;"     >> "$PROXY_CONFIG_FILE"
    echo "    proxy_timeout 3s;"             >> "$PROXY_CONFIG_FILE"
    echo "    proxy_pass $CURRENT_IP:$PORT;" >> "$PROXY_CONFIG_FILE"
    echo "}"                                 >> "$PROXY_CONFIG_FILE"
    nginx -s reload
else
    old=`cat "$IP_TEMP_FILE" |head -n 1`

    if [ "$old" != "$CURRENT_IP" ];then
        nginx -s reload
        echo "$CURRENT_IP" > "$IP_TEMP_FILE"
    fi
fi


