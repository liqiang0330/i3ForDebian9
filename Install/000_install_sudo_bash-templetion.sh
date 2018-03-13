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

function commandSuccess() {
    if [ $1 -eq 0 ] ;then
        print_dot 
        echo -e "\033[32m $2  Successful !  \033[0m"
        print_dot 
        sleep 3
    else
        print_dot 
        echo -e "\033[31m $2  Failed !!!  \033[0m"
        print_dot 
        exit
    fi
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
  echo "deb https://mirrors.ustc.edu.cn/debiancn/ buster main" | tee /etc/apt/sources.list.d/debiancn.list
  wget -c https://mirrors.ustc.edu.cn/debiancn/debiancn-keyring_0~20161212_all.deb -O debiancn-keyring.deb
  apt -y install ./debiancn-keyring.deb
  commandSuccess $? "Add DebianCN Sources List "
  apt -y update && apt -y upgrade
}

function addUserToSudo() {
  #statements
  print_dot
  echo -e "\033[31m Install sudo , bash-completion , x11 . Add username to sudoers , open Shell Tab completion . \033[0m"
  print_dot
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

function installDevice() {
  #statements
  echo -en "\033[33m Please select install option [vir == VirtualBox ; Other == Your computer] :  \033[0m"
  read option
  case $option in
    vir )
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') \
        linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') \
        linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,')
    commandSuccess $? "Linux-headers , Linux-image Installation "
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
    * )
    apt -y install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') \
        linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
    modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    modprobe wl
    commandSuccess $? "BCM WIFI device driver Installation "
    apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') \
        linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
    # 不开i386了, 没啥用得到的
    # dpkg --add-architecture i386 &&
    apt -y update && apt -y install bumblebee-nvidia primus # primus-libs:i386
    commandSuccess $? "Bumblebee software Installation "
    if [ ! -n "$username" ];then
        echo -en "\033[33m Please input you create username , It add to  bumblebee! :  \033[0m"
        read username 
    fi
    print_dot 
    echo -e "\033[33m UserName : $username \033[0m"
    print_dot 
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
        firmware-brcm80211 nvidia-smi
    commandSuccess $? "Xserver BCM driver Nvidia-smi Installation "
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
    print_dot
    echo "Configure software Source List And add DebianCN Source List "
    print_dot 
    installSourcesAndDebiancnSources
    # 安装 sudo , bash-completion . 开启 sudo 和 shell Tab 补全
    print_dot 
    echo "Install sudo bash-completion , add UserName to sudoers "
    print_dot 
    addUserToSudo
    print_dot 
    echo "Open Bash Completion "
    print_dot 
    openBashCompletion
    # 安装 X 环境 , 和一些驱动驱动
    print_dot 
    echo "Install Devices driver and Xservers "
    print_dot 
    installDevice
    # 关闭 pcspkr 警告音
    echo "Close Terminal TTY Warning tone "
    print_dot 
    removePcspkr
    # 清除临时目录 ( 当前为 root 目录下的workPath )
    print_dot 
    echo "Clear Install script temporary directory "
    print_dot 
    rm -rf $workPath
    commandSuccess $? "Clear script WorkPath Cache "
}

main
