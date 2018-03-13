#!/bin/bash
workPath="$HOME/i3ForDebian9"
# 打印字符*
function print_dot() {
  #statements
  echo
  for (( i = 0; i < 80; i++ )); do
    #statements
    echo -en "\033[33m*\033[0m"
  done
  echo
  echo
}

function print_dash() {
    echo
    for (( i = 0; i < 80; i++ )); do
        echo -en "\033[33m-\033[0m"
    done
    echo
    echo
}

function print_info() {
    print_dot
    echo "$1"
    print_dot
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

function commandSuccess() {
    if [ $1 -eq 0 ] ;then
        print_dash
        echo -e "\033[32m $2  Successful !  \033[0m"
        print_dash
    else
        print_dash
        echo -e "\033[31m $2  Failed !!!  \033[0m"
        print_dash
        exit
    fi
}

function installSourcesAndDebiancnSources() {
  #statements
  installCache
  print_info "Replace apt sources list to << USTC >> for china. And update upgrade Your system."
  wget -c https://mirrors.ustc.edu.cn/repogen/conf/debian-https-4-buster -O sources.list
  cp -rf sources.list /etc/apt/
  chmod 644 /etc/apt/sources.list
  chown root:root /etc/apt/sources.list
  # 添加 Debiancn 源
  echo "deb https://mirrors.ustc.edu.cn/debiancn/ buster main" | tee /etc/apt/sources.list.d/debiancn.list
  wget -c https://mirrors.ustc.edu.cn/debiancn/debiancn-keyring_0~20161212_all.deb -O debiancn-keyring.deb
  apt -y install ./debiancn-keyring.deb
  commandSuccess $? "Add DebianCN Sources List "
  apt -y update && apt -y upgrade
}

function addUserToSudo() {
  #statements
  print_info "Install sudo , bash-completion , x11 . Add username to sudoers , open Shell Tab completion ."
  apt -y update
  apt -y install sudo bash-completion
  commandSuccess $? "Sudo And Bash-completion Installation"
  echo -en "\033[33m Please input you create username :  \033[0m"
  read username
  # sed "20 a$username    ALL=(ALL:ALL) ALL" -i /etc/sudoers
  sed -i "/root	ALL=(ALL:ALL) ALL/a$username	ALL=(ALL:ALL) ALL" /etc/sudoers
}

function openBashCompletion() {
  #statements
cat <<BASH_COMPLETION | tee -a /etc/bash.bashrc
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

function installLinuxHeadersAndLinuxImage() {
  #statements
  apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') \
      linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') \
      linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,')
  commandSuccess $? "Linux-headers , Linux-image Installation "
}

function installBCMDeviceDriver() {
  #statements
  echo
  echo -en "\033[33m You need Install BCM WIFI device driver ? ( Input y or other ) :  \033[0m"
  read action
  case $action in
    y )
    apt -y install linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
    apt -y install firmware-brcm80211
    modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    modprobe wl
    commandSuccess $? "BCM WIFI device driver Installation "
      ;;
    * )
    exit
      ;;
  esac
}

function installDevice() {
  #statements
  echo -en "\033[33m Please select install option [vir == VirtualBox ; in == Intel + Nvidia ; pc == Nvidia ; other == exit ] :  \033[0m"
  read option
  case $option in
    vir )
    print_info "Install LinuxHeaders And LinuxImage "
    installLinuxHeadersAndLinuxImage
    apt -y install xserver-xorg-input-evdev \
        xserver-xorg-input-kbd \
        xserver-xorg-input-mouse \
        xserver-xorg-input-synaptics \
        xserver-xorg-video-vesa \
        xserver-xorg-video-vmware \
        x11-xserver-utils \
        x11-utils \
        x11-xkb-utils #virtualbox-guest-x11 virtualbox-guest-utils
    commandSuccess $? "Xserver ... Installation "
    apt -y install build-essential make perl
    mount /dev/sr0 /mnt/ && cd /mnt
    ./VBoxLinuxAdditions.run
    commandSuccess $? "VBoxLinuxAdditions Installation "
      ;;
    in )
    print_info "Install LinuxHeaders And LinuxImage "
    installLinuxHeadersAndLinuxImage
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
    # 不开i386了, 没啥用得到的
    # dpkg --add-architecture i386 &&
    apt -y update && apt -y install bumblebee-nvidia primus # primus-libs:i386
    commandSuccess $? "Bumblebee software Installation "
    if [ ! -n "$username" ];then
        echo -en "\033[33m Please input you create username , It add to  bumblebee! :  \033[0m"
        read username
    fi
    print_info "UserName : $username "
    adduser $username bumblebee
    commandSuccess $? "Add Bumblebee group "
    # IntelGraphics=$(lspci | grep "VGA" | grep "Intel" | cut -d' ' -f 1)
    # NvidiaGraphics=$(lspci | grep "VGA" | grep "NVIDIA" | cut -d' ' -f 1)
    # sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$IntelGraphics\"" /etc/bumblebee/xorg.conf.nouveau
    # sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$NvidiaGraphics\"" /etc/bumblebee/xorg.conf.nvidia
    apt -y install xserver-xorg-input-evdev \
        xserver-xorg-input-kbd \
        xserver-xorg-input-mouse \
        xserver-xorg-input-synaptics \
        x11-xserver-utils \
        x11-utils x11-xkb-utils \
        nvidia-smi xserver-xorg-video-intel
    commandSuccess $? "Xserver BCM driver Nvidia-smi Installation "
      ;;
    pc )
    print_info "Install LinuxHeaders And LinuxImage "
    installLinuxHeadersAndLinuxImage
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
    commandSuccess $? "Nvidia driver Installation "
    apt -y install xserver-xorg-input-evdev \
        xserver-xorg-input-kbd \
        xserver-xorg-input-mouse \
        xserver-xorg-input-synaptics \
        x11-xserver-utils \
        x11-utils x11-xkb-utils \
        nvidia-smi nvidia-xconfig
    commandSuccess $? "Xserver BCM driver Nvidia-smi Installation "
    nvidia-xconfig
      ;;
    * )
    exit
      ;;
  esac
}

function removePcspkr() {
  #statements
  echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
  modprobe -r pcspkr
  commandSuccess $? "Close Pcspkr "
}

function main() {

    # 更换软件源为 ustc
    print_info "Configure software Source List And add DebianCN Source List "
    installSourcesAndDebiancnSources
    # 安装 sudo , bash-completion . 开启 sudo 和 shell Tab 补全
    print_info "Install sudo bash-completion , add UserName to sudoers "
    addUserToSudo
    print_info "Open Bash Completion "
    openBashCompletion
    # 安装 X 环境 , 和一些驱动驱动
    print_info "Install Devices driver and Xservers "
    installDevice
    print_info "Install BCM Devices driver "
    installBCMDeviceDriver
    # 关闭 pcspkr 警告音
    print_info "Close Terminal TTY Warning tone "
    removePcspkr
    # 清除临时目录 ( 当前为 root 目录下的workPath )
    print_info "Clear Install script temporary directory "
    rm -rf $workPath
    commandSuccess $? "Clear script WorkPath Cache "
}

main
