#! /bin/bash

if [ ! -n "$SET_NAME" ] || [ ! -n "$PODS_NUM" ];then
    echo "PARAMS ERROR!"
    exit 1
fi

CONFIG_DIR=/etc/nginx/conf.d/stream
IP_TEMP_DIR=/temp

if [ ! -d "$CONFIG_DIR" ]; then  
　　mkdir -p "$CONFIG_DIR"  
fi  

if [ ! -d "$IP_TEMP_DIR" ]; then  
　　mkdir "$IP_TEMP_DIR"  
fi  

max=$PODS_NUM

for i in `seq 0 $max`;do
    echo "* * * * * /reflash.sh $SET_NAME $i 37021 default" >> /etc/crontabs/root
done
