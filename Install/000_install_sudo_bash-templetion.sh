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
function installDevice() {
  #statements
  echo -en "\033[33m Please select install option [vir == VirtualBox ; Other == Your computer] :  \033[0m"
  read option
  case $option in
    vir )
    apt install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,')
    apt install xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-input-synaptics xserver-xorg-video-vesa xserver-xorg-video-vmware x11-xserver-utils x11-utils x11-xkb-utils virtualbox-guest-x11 virtualbox-guest-utils
    apt install apt install build-essential make perl
    mount /dev/sr0 /mnt/ && cd /mnt
    ./VBoxLinuxAdditions.run
      ;;
    * )
    apt install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
    apt install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
    modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    modprobe wl
    apt install xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-input-synaptics x11-xserver-utils x11-utils x11-xkb-utils
      ;;
  esac
}
function addUserToSudo() {
  #statements
  echo -en "\033[33m Please input you create username :  \033[0m"
  read username
  sed "20 a$username    ALL=(ALL:ALL) ALL" -i /etc/sudoers
}
function openBashCompletion() {
  #statements
cat <<BASH_COMPLETION | sudo tee -a /etc/bash.bashrc
# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
BASH_COMPLETION
}

print_dot
echo -e "\033[31m Install sudo , bash-completion , x11 . Add username to sudoers , open Shell Tab completion . \033[0m"
print_dot
# 安装 sudo , bash-completion . 开启 sudo 和 shell Tab 补全
apt update
apt install sudo bash-completion
addUserToSudo
openBashCompletion
# 安装 X 环境 , 和一些驱动驱动
installDevice
