#!/bin/bash

function updateSoftWareAndSystemLogs() {
    userHome=limo
    echo "$(date '+%d/%m/%Y %H:%M:%S') ------ Update System SoftWare $1" | tee -a /home/$userHome/.config/polybar/script/updateSoftWareAndSystem.log
}

apt update

if [ $? -eq 0 ];then
    updateSoftWareAndSystemLogs "Successful !"
else
    updateSoftWareAndSystemLogs "Failed !"
fi
