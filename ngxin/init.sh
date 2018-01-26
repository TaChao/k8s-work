#! /bin/bash

if [ $# -lt 4 ]; then
    echo $0 parameters err
    exit 1
fi

SET_NAME=$1
PODS_NUM=$2
PORT=$3
NAMESPACE=$4

CONFIG_DIR=/etc/nginx/conf.d/stream
IP_TEMP_DIR=/temp

if [ ! -d "$CONFIG_DIR" ]; then  
    mkdir -p "$CONFIG_DIR"  
fi  

if [ ! -d "$IP_TEMP_DIR" ]; then  
    mkdir "$IP_TEMP_DIR"  
fi  

for i in `seq 0 $PODS_NUM`;do
    echo "* * * * * /script/reflash.sh $SET_NAME $i $PORT $NAMESPACE" >> /etc/crontabs/root
done
