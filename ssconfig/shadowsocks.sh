#!/bin/bash

shadowsocksPath="$HOME/ssconfig"
function ssr_ip() {
  #statements
  local_ip=$(curl ip.sb/ip)
  ssr_ip=$(proxychains4 curl ip.sb/ip)
  echo "$local_ip"
  echo "$ssr_ip"
}
function main() {
  #statements
  case $1 in
    s | start )
    ~/shadowsocksr/shadowsocks/local.py -c ~/ssconfig/config.json --pid-file ~/ssconfig/shadowsocks.pid --log-file ~/ssconfig/shadowsocks.log -d start
    sleep 1
    if [[ -e "$shadowsocksPath/shadowsocks.pid"  ]]; then
      #statements
      ssr_ip
      notify-send "SSR" "启动成功.若无法上网,请检查配置文件信息是否正确!\\n本机_IP: $local_ip\\nSSR_IP: $ssr_ip" -i ~/ssconfig/ssr.png
    elif [[ ! -e "$shadowsocksPath/shadowsocks.pid" ]]; then
      #statements
      notify-send "SSR" "启动失败,请检查配置文件是否正确" -i ~/ssconfig/ssr.png
    fi
      ;;
    e | stop )
    ~/shadowsocksr/shadowsocks/local.py -c ~/ssconfig/config.json --pid-file ~/ssconfig/shadowsocks.pid --log-file ~/ssconfig/shadowsocks.log -d stop
    sleep 1
    if [[ -e "$shadowsocksPath/shadowsocks.pid"  ]]; then
      #statements
      notify-send "SSR" "停止失败..." -i ~/ssconfig/ssr.png
    elif [[ ! -e "$shadowsocksPath/shadowsocks.pid" ]]; then
      #statements
      notify-send "SSR" "停止成功..." -i ~/ssconfig/ssr.png
    fi
      ;;
    r | restart )
    ~/shadowsocksr/shadowsocks/local.py -c ~/ssconfig/config.json --pid-file ~/ssconfig/shadowsocks.pid --log-file ~/ssconfig/shadowsocks.log -d restart
    sleep 1
    if [[ -e "$shadowsocksPath/shadowsocks.pid"  ]]; then
      #statements
      ssr_ip
      notify-send "SSR" "重启成功.若无法上网,请检查配置文件信息是否正确!\\n本机_IP: $local_ip\\nSSR_IP: $ssr_ip" -i ~/ssconfig/ssr.png

    elif [[ ! -e "$shadowsocksPath/shadowsocks.pid" ]]; then
      #statements
      notify-send "SSR" "重启失败,请检查配置文件是否正确..." -i ~/ssconfig/ssr.png
    fi
      ;;
  esac
}

if [[ ! -e "$shadowsocksPath/config.json"  ]]; then
  #statements
  notify-send "SSR" "启动失败, 未在 $HOME/ssconfig 中找到config.json 配置文件.请创建节点文件后通过 i3wm快捷键 Mod(当前为win键) + F12 重启SSR." -i ~/ssconfig/ssr.png
else
  main $1
fi
