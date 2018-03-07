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
    rm -rf $workPath/.cache
  fi
  mkdir -p $workPath/.cache
  cd $workPath/.cache
}

function installSourcesAndDebiancnSources() {
  #statements
  installCache
  print_dot
  echo "Replace apt sources list to << USTC >> for china. And update upgrade Your system."
  print_dot
  wget -c https://mirrors.ustc.edu.cn/repogen/conf/debian-https-4-buster -O sources.list
  cp -rf sources.list /etc/apt/
  chmod 644 /etc/apt/sources.list
  chown root:root /etc/apt/sources.list
  # 添加 Debiancn 源
  echo "deb https://mirrors.ustc.edu.cn/debiancn/ buster main" | sudo tee /etc/apt/sources.list.d/debiancn.list
  wget -c https://mirrors.ustc.edu.cn/debiancn/debiancn-keyring_0~20161212_all.deb -O debiancn-keyring.deb
  apt -y install ./debiancn-keyring.deb
  apt -y update && sudo apt -y upgrade
  rm -rf sources.list
  rm -rf debiancn-keyring.deb
}

function addUserToSudo() {
  #statements
  print_dot
  echo -e "\033[31m Install sudo , bash-completion , x11 . Add username to sudoers , open Shell Tab completion . \033[0m"
  print_dot
  apt -y update
  apt -y install sudo bash-completion
  echo -en "\033[33m Please input you create username :  \033[0m"
  read username
  # sed "20 a$username    ALL=(ALL:ALL) ALL" -i /etc/sudoers
    sed -i "/root	ALL=(ALL:ALL) ALL/a$username	ALL=(ALL:ALL) ALL"
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

function installDevice() {
  #statements
  echo -en "\033[33m Please select install option [vir == VirtualBox ; Other == Your computer] :  \033[0m"
  read option
  case $option in
    vir )
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,')
    apt -y install xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-input-synaptics xserver-xorg-video-vesa xserver-xorg-video-vmware x11-xserver-utils x11-utils x11-xkb-utils #virtualbox-guest-x11 virtualbox-guest-utils
    apt -y install build-essential make perl
    mount /dev/sr0 /mnt/ && cd /mnt
    ./VBoxLinuxAdditions.run
      ;;
    * )
    apt -y install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
    modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    modprobe wl
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
    dpkg --add-architecture i386 && apt -y update && apt -y install bumblebee-nvidia primus primus-libs:i386
    echo -en "\033[33m Please input you create username , It add to  bumblebee! :  \033[0m"
    read username
    echo -e "\033[33m UserName : $username \033[0m"
    adduser $username bumblebee
    IntelGraphics=$(lspci | grep "VGA" | grep "Intel" | cut -d' ' -f 1)
    NvidiaGraphics=$(lspci | grep "VGA" | grep "NVIDIA" | cut -d' ' -f 1)
    sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$IntelGraphics\"" /etc/bumblebee/xorg.conf.nouveau
    sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$NvidiaGraphics\"" /etc/bumblebee/xorg.conf.nvidia
    apt -y install xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-input-synaptics x11-xserver-utils x11-utils x11-xkb-utils
      ;;
  esac
}

# 更换软件源为 ustc
installSourcesAndDebiancnSources
# 安装 sudo , bash-completion . 开启 sudo 和 shell Tab 补全
addUserToSudo
openBashCompletion
# 安装 X 环境 , 和一些驱动驱动
installDevice
# 清除临时目录
rm -rf $workPath/.cache
