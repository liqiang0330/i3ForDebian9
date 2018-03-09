# i3 For Debian9 Testing 备份
------
## 安装方式

#### 最小化安装 Debian9 Testing , [官方NetBootNonFreeWeeklyISO镜像](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/weekly-builds/amd64/iso-cd/)
#### 安装完成后使用普通用户登录 tty
#### 克隆该仓库到 HOME 目录
```sh
cd ~
apt update
apt install git
git clone https://github.com/LimoYuan/i3ForDebian9.git
```
### VirtualBox 安装:
```sh
cd ~/i3ForDebian9/Install
# 点击虚拟机的安装增强功能后继续
# 切换到 root 用户
su root
# 执行 000_install_sudo_bash-templetion.sh
./000_install_sudo_bash-templetion.sh
# 看到 tty 提示 Please select install option [vir == VirtualBox ; Other == Your computer] 时 , 输入 vir
# 安装过程中需要输入你创建的普通用户账号 , 具体看到提示后操作
# 000 脚本安装完成后 , 切换到你创建的普通用户
su youCreateUsername #你创建的普通用户
# 执行 001 脚本
./001_install_driver_and_app.sh
# 安装过程中需要你输入一些信息 , 请按提示输入
# 001 脚本中会安装 OhMyZsh , OhMyZsh 安装后会自动进入 zsh , 请输入 exit 退出后继续
# 脚本安装完成会自动重启
```
### Intel + NVIDIA 双显卡笔记本安装
#### 安装步骤同上 , 区别是看到 tty 提示 Please select install option [vir == VirtualBox ; Other == Your computer] 时 , 输入其他字符或者直接回车
#### 暂时只支持这两种安装方式 , 对于NVIDIA 单显卡用户 , 只需修改 000 中安装显卡驱动部分
```sh
# 这几行是为 BCM 无线网卡模块需要的代码 , 如果你不是 BCM 无线网卡 , 请注释掉这几行
#############################
# apt -y install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
# modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
# modprobe wl
#
############################
apt -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver
# 单 NVIDIA 显卡 , 只需要注释下面这几行
# dpkg --add-architecture i386 && apt -y update && apt -y install bumblebee-nvidia primus primus-libs:i386
# echo -en "\033[33m Please input you create username , It add to  bumblebee! :  \033[0m"
# read username
# echo -e "\033[33m UserName : $username \033[0m"
# adduser $username bumblebee
# IntelGraphics=$(lspci | grep "VGA" | grep "Intel" | cut -d' ' -f 1)
# NvidiaGraphics=$(lspci | grep "VGA" | grep "NVIDIA" | cut -d' ' -f 1)
# sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$IntelGraphics\"" /etc/bumblebee/xorg.conf.nouveau
# sed -i "/#   BusID \"PCI:01:00:0\"/a\BusID \"PCI:$NvidiaGraphics\"" /etc/bumblebee/xorg.conf.nvidia
# 然后在下一行中添加 xserver-xorg-video-nvidia , nvidia-xconfig
# 看是这样
apt -y install xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-input-synaptics x11-xserver-utils x11-utils x11-xkb-utils firmware-brcm80211 xserver-xorg-video-nvidia nvidia-xconfig # 其中 firmware-brcm80211 也是 BCM 无线网卡需要安装的驱动 , 如果你不是 BCM 无线网卡 , 请删掉它
# 然后增加下面这条命令 , 便可执行脚本
nvidia-xconfig
# 理论上现在你可以按照上面的步骤进行安装该脚本了
```
## 脚本中安装的所有软件包(待添加)
#LimoYuan
## i3wm快捷方式(待添加)
#
## 截图(待添加)
#
## 该脚本使用到的一些程序和文件来自 :
#### [i3Gaps](https://github.com/Airblader/i3)
#### [Polybar](https://github.com/jaagr/polybar)
#### [lightdm-webkit2-greeter](https://github.com/Antergos/web-greeter)
#### [lightdm-webkit2-greeter_Themes](https://github.com/NoiSek/Aether)
#### [Fonts_awesome](https://fontawesome.com/)
#### [Fonts_material-design-icons](https://github.com/google/material-design-icons)
#### [Fonts_Setting](https://ohmyarch.github.io/2017/01/15/Linux%E4%B8%8B%E7%BB%88%E6%9E%81%E5%AD%97%E4%BD%93%E9%85%8D%E7%BD%AE%E6%96%B9%E6%A1%88/)
#### [Grub_Themes](https://github.com/vinceliuice/grub2-themes)
#### [Shadowsocksr_python](https://github.com/shadowsocksr-backup/shadowsocksr)
#### [Proxychains-ng](https://github.com/rofl0r/proxychains-ng)
#### [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh)
#### 诚谢以上项目 . 可能还有其他没有列出 . 之后再添加
