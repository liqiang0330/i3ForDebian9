#!/bin/bash
workPath="$HOME/i3ForDebian9"
# 打印字符*
function print_dot() {
  #statements
  echo
  for (( i = 0; i < 50; i++ )); do
    #statements
    echo -n "*"
  done
  echo
  echo
}
# 创建脚本工作时的临时目录
function installCache() {
  #statements
  if [[ -d "$workPath/.cache" ]]; then
    #statements
    sudo rm -rf $workPath/.cache
  fi
  mkdir -p $workPath/.cache
  cd $workPath/.cache
}

function installApplications() {
  #statements
  sudo apt -y update
  sudo apt -y install lightdm i3 git vim neofetch feh fonts-wqy-zenhei lxappearance gdebi qt4-qtconfig compton curl wget ranger volumeicon-alsa pulseaudio pavucontrol fonts-arphic-uming arandr xdg-utils wpasupplicant wpagui htop p7zip-full xfce4-terminal xfce4-notifyd zsh xfce4-power-manager* thunar breeze-cursor-theme file-roller pulseaudio-module-bluetooth blueman rofi xbindkeys zsh-syntax-highlighting scrot imagemagick zathura*
}
# 安装需要的软件
installApplications
# 生成 XDG_HOME_CONFIG
xdg-user-dirs-update
