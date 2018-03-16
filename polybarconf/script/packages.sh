#!/bin/bash
packages=$(echo "$(aptitude full-upgrade --simulate --assume-yes)" | grep "个软件包被升级" | cut -d' ' -f 1)
if [[ !($packages -eq 0) ]];then
    echo "%{F#ff5c56} Pkg : $packages"
fi
