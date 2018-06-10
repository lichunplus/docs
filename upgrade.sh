#!/bin/bash
while read host
do
    scp rcos-vmtools-1.0.0.rpm root@${host}:/tmp  > /dev/null 2>&1 &&
    ssh -n root@${host} rpm -e rcos-vmtools > /dev/null 2>&1 &&
    ssh -n root@${host} rpm -ivh /tmp/rcos-vmtools-1.0.0.rpm > /dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "Failed to upgrade RPM on ${host}"
        exit 1
    fi
    echo "${host} upgraded"
done <<< '172.21.129.11
172.21.129.11
172.21.129.11
172.21.129.11'