#!/bin/bash
action=$(echo -e "scrot\nlock\nlogout\nshutdown\nreboot" | rofi -dmenu -p "power:")

if [[ "$action" == "scrot" ]]
then
    sleep 1
    scrot -e 'mv $f \$HOME/Pictures/'
fi

if [[ "$action" == "lock" ]]
then
    ~/.config/i3/i3lock-fancy-multimonitor/lock
fi

if [[ "$action" == "logout" ]]
then
    i3-msg exit
fi

if [[ "$action" == "shutdown" ]]
then
    shutdown now
fi

if [[ "$action" == "reboot" ]]
then
    reboot
fi
