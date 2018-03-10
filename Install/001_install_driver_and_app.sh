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
  sudo apt -y install lightdm i3 git vim neofetch feh resolvconf \
      fonts-wqy-zenhei lxappearance gdebi qt4-qtconfig compton \
      curl wget ranger volumeicon-alsa alsa-utils pulseaudio \
      pavucontrol fonts-arphic-uming arandr xdg-utils \
      wpasupplicant htop p7zip-full xfce4-terminal \
      xfce4-notifyd zsh xfce4-power-manager* thunar \
      breeze-cursor-theme file-roller pulseaudio-module-bluetooth \
      blueman rofi xbindkeys zsh-syntax-highlighting scrot \
      imagemagick zathura* notify-osd tk parcellite network-manager network-manager-gnome
}

function someNeedsApplications() {
  #statements
  # 安装 fcitx 输入法支持
  sudo apt -y install fcitx fcitx-data fcitx-frontend-qt4 \
      fcitx-libs-qt fcitx-module-x11 fcitx-bin fcitx-frontend-all \
      fcitx-frontend-qt5 fcitx-table fcitx-config-common \
      fcitx-frontend-fbterm fcitx-libs fcitx-module-dbus \
      fcitx-table-wubi fcitx-config-gtk fcitx-frontend-gtk2 \
      fcitx-libs-dev fcitx-module-kimpanel fcitx-ui-classic \
      fcitx-config-gtk2 fcitx-frontend-gtk3 fcitx-modules
  # 安装 telegram , Chrome , sogoupinyin , Atom , VSCode
  sudo apt -y update
  sudo apt -y install telegram-desktop google-chrome-stable \
      sogoupinyin atom code numix-gtk-theme numix-icon-theme
  # 卸载 dunst ,因为它与 xfce4-notifyd 会发生冲突
  # 卸载 NetworkManager
  sudo apt -y purge dunst notification-daemon
}

function installLightdmWebKit2() {
  #statements
  installCache
  echo 'deb http://download.opensuse.org/repositories/home:/antergos/Debian_9.0/ /' | sudo tee /etc/apt/sources.list.d/home:antergos.list
  wget -nv https://download.opensuse.org/repositories/home:antergos/Debian_9.0/Release.key -O Release.key
  sudo apt-key add - < Release.key
  sudo apt -y update
  sudo apt -y install lightdm-webkit2-greeter

  # 更改默认ubuntu默认的unity-greeter为lightdm-webkit2-greeter
  sudo sed -i '/#greeter-session=example-gtk-gnome/agreeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
  # 更换"lightdm-webkit2-greeter"主题为aether
  sudo cp -rf $workPath/Aether /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
  sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
}

function installGrub2Themes() {
  #statements
  # 更改Grub2主题
  sudo mkdir -p /boot/grub/themes
  sudo cp -rf $workPath/grub2-themes/* /boot/grub/themes
  sudo grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"/boot/grub/themes/Vimix/theme.txt\"" | sudo tee -a /etc/default/grub
  sudo update-grub
}

function installOsxArcThemes() {
  #statements
  sudo gdebi -n $workPath/osx-arc/osx-arc*.deb
}

function installOhMyZsh() {
  #statements
  # 安装ohmyzsh
  cd $HOME
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  # 安装zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  installCache
}

function configDNS() {
  #statements
  # 添加 DNS
  echo "Configure DNS"
  cat <<DNS_RESOLV_CONF | sudo tee /etc/resolvconf/resolv.conf.d/head
nameserver 223.5.5.5
nameserver 8.8.8.8
DNS_RESOLV_CONF
  sudo resolvconf -u &&  sudo resolvconf --enable-updates
}

function installFonts() {
  #statements
# 安装字体以及字体配置
  installCache
  bash $workPath/fonts/fonts-master/install.sh
  sudo cp -rf $workPath/fonts/noto* /usr/share/fonts/truetype/
  sudo cp -rf $workPath/fonts/fontConfig/66-noto* /etc/fonts/conf.avail/
  # wget -c https://raw.githubusercontent.com/ohmyarch/fontconfig-zh-cn/master/fonts.conf
  mkdir -p $HOME/.config/fontconfig
  mkdir -p $HOME/.local/share/fonts
  mkdir -p $HOME/.config/fontconfig/conf.d
  cp -rf $workPath/fonts/fontConfig/fonts.conf $HOME/.config/fontconfig
  rm -rf $HOME/.config/fontconfig/conf.d/10-powerline-symbols.conf
  cp -rf $workPath/fonts/fontConfig/10-powerline-symbols.conf $HOME/.config/fontconfig/conf.d
  cp -rf $workPath/fonts/Mesl* $HOME/.local/share/fonts
  cp -rf $workPath/fonts/myfonts $HOME/.local/share/fonts
  cp -rf $workPath/fonts/fontawesome $HOME/.local/share/fonts
  sudo chown root:root /usr/share/fonts/truetype/noto
  sudo chown root:root /usr/share/fonts/truetype/noto-cjk
  cd /usr/share/fonts/truetype/noto
  sudo chmod 644 *
  sudo chown root:root *
  cd /usr/share/fonts/truetype/noto-cjk
  sudo chmod 644 *
  sudo chown root:root *
  sudo chmod 644 /etc/fonts/conf.avail/66-noto*
  sudo chown root:root /etc/fonts/conf.avail/66-noto*
  # 更新字体缓存
  print_dot
  echo "Fonts installed , Updating font cache . "
  print_dot
  sudo fc-cache --force --verbose
  # 生成 XDG_HOME_CONFIG
  xdg-user-dirs-update
  sudo dpkg-reconfigure locales
  sudo sed -i 's/LANGUAGE="en_US:en"/LANGUAGE="zh_CN"/g' /etc/default/locale
  installCache
}

function installProxyChains() {
  #statements
  installCache
  cp -rf $workPath/proxychains-ng $workPath/.cache
  sudo apt -y install build-essential
  cd proxychains-ng
  ./configure --prefix=/usr --sysconfdir=/etc
  make
  sudo make install
  sudo make install-config
  # 配置 proxychains.conf . 默认端口改为 1088 . 请自行修改为自己节点设置的端口
  sudo sed -i 's/socks4 	127.0.0.1 9050/socks5  127.0.0.1 1088/g' /etc/proxychains.conf
}

function installShadowsocksr() {
  #statements
  sudo apt install libsodium23
  cp -rf $workPath/shadowsocksr $HOME
  # 请自行添加名为 config.json 的配置文件到 ~/ssconfig目录中
  cp -rf $workPath/ssconfig $HOME
}

function installI3Gaps() {
  #statements
  installCache
  # 安装依赖
  sudo apt -y install libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb \
                                  libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev \
                                  libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev \
                                  libxkbcommon-x11-dev libstartup-notification0-dev \
                                  libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev
    cp -rf $workPath/i3-gaps/i3-gaps.tar.gz $workPath/.cache && tar -zxvf i3-gaps.tar.gz
    # git clone https://www.github.com/Airblader/i3 $workPath/.cache/i3-gaps
    cd $workPath/.cache/i3-gaps
    # compile & install
    autoreconf --force --install
    rm -rf build/
    mkdir -p build && cd build/
    # Disabling sanitizers is important for release versions!
    # The prefix and sysconfdir are, obviously, dependent on the distribution.
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
    make -j8
    sudo make install
}

function installPolybar() {
  #statements
  installCache
  # 安装 依赖
  sudo apt -y install cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
      libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev \
      libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm \
      libjsoncpp-dev libasound2-dev libpulse-dev libmpdclient-dev \
      libiw-dev libcurl4-openssl-dev libxcb-cursor-dev
  cp -rf $workPath/polybar $workPath/.cache
  mkdir polybar/build
  cd polybar/build
  cmake ..
  sudo make install
  make userconfig
}

function installMpdNcmpcpp() {
  #statements
  # 尝试删除旧的安装包 (如果存在)
  sudo apt -y remove --purge mpd ncmpcpp && sudo apt -y autoremove
  sudo rm -rf /etc/mpd.conf
  sudo rm -rf $HOME/.config/mpd
  sudo rm -rf $HOME/.mpd
  # 安装 mpd ncmpcpp
  sudo apt -y install mpd ncmpcpp
  sudo systemctl stop mpd
  sudo systemctl disable mpd
  sudo rm -rf /etc/mpd.conf
  # 配置 mpd ncmpcpp 需要的目录或文件
  mkdir -p $HOME/.mpd/playlists
  sudo cp -rf $workPath/mpd_ncmpcpp/mpd.conf $HOME/.mpd
  touch $HOME/.mpd/{mpd.db,mpd.log,mpd.pid,mpdstate}
  # 移动 ncmpcpp 的配置文件到 XDG_HOME_CONFIG
  cp -rf $workPath/mpd_ncmpcpp/.ncmpcpp $HOME
  sudo usermod -aG pulse,pulse-access mpd
}

function installVimPlus() {
  #statements
  # Delete old files . if has .
  rm -rf $HOME/.vim
  rm -rf $HOME/.vimrc
  rm -rf $HOME/.vimrc.local
  rm -rf $HOME/.ycm_extra_conf.py
  mkdir -p $HOME/.vim
  # 复制文件
  cp -rf $workPath/vimConfig/* $HOME/.vim/
  cp -rf $workPath/vimConfig/.vimrc $HOME/.vim/
  cp -rf $workPath/vimConfig/.vimrc.local $HOME/.vim/
  cp -rf $workPath/vimConfig/.ycm_extra_conf.py $HOME/.vim/
  cp -rf $HOME/.vim/.vimrc $HOME
  cp -rf $HOME/.vim/.vimrc.local $HOME
  cp -rf $HOME/.vim/.ycm_extra_conf.py $HOME
  # git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  # 安装编译 YCM 所需依赖
  sudo apt-get install -y ctags build-essential cmake python-dev python3-dev vim-nox
  # 解压 bundle 文件
  cd $HOME/.vim && tar -zxvf bundle.tar.gz
  # 编译安装 YCM
  cp -rf $workPath/YouCompleteMe $HOME/.vim/bundle
  cd $HOME/.vim/bundle/YouCompleteMe
  sudo ./install.py --clang-completer
  vim -c "PluginInstall" -c "q" -c "q"
  # 改变一些文件、文件夹属组和用户关系
  who_is=$(who)
  current_user=${who_is%% *}
  sudo chown -R ${current_user}:${current_user} ~/.vim
  sudo chown -R ${current_user}:${current_user} ~/.cache
  # sudo chown ${current_user}:${current_user} ~/.vimrc
  sudo chown ${current_user}:${current_user} ~/.vimrc.local
  sudo chown ${current_user}:${current_user} ~/.viminfo
  # sudo chown ${current_user}:${current_user} ~/.ycm_extra_conf.py
  # 删除 bundle.tar.gz
  rm -rf $HOME/.vim/bundle.tar.gz
  installCache
}

function installBluetooth() {
  #statements
  # 安装蓝牙驱动,这不适合所有用户
    echo -e "\033[33m Install Bluetooth driver , Only applies to BCM94352HMB device. \033[0m"
    echo -en "\033[33m Your Bluetooth device is BCM94352HMB ? Input:  ( y or other ) \033[0m"
    read action
    case $action in
      y )
       sudo cp -rf $workPath/bluetooth/BCM207*.hcd /lib/firmware/brcm
       echo -e "\033[33m  Update your system , Remove not software. \033[0m"
       sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove
       echo
       echo
       echo -e "\033[33m  Install script is successful . 5 sec after Reboot system. \033[0m"
       echo
       echo
       sleep 5
       sudo reboot
        ;;
      * )
      echo -e "\033[33m  Update your system , Remove not software. \033[0m"
      sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove
      echo
      echo
      echo -e "\033[33m  Install script is successful . 5 sec after Reboot system. \033[0m"
      echo
      echo
      sleep 5
      sudo reboot
        ;;
    esac
}

function someConfigure() {
  #statements
  # 更改默认shell为zsh
  chsh -s /usr/bin/zsh
  # 创建未重启没有自动创建的文件夹
  mkdir -p $HOME/.config/i3
  cp -rf $workPath/.zshrc $HOME
  # 移动壁纸到家目录
  cp -rf $workPath/.wallpaper.png $HOME
  # 移动头像到家目录
  cp -rf $workPath/.face $HOME
  # 配置并加载 .Xresources
  cp -rf $workPath/.Xresources $HOME
  xrdb -merge $HOME/.Xresources
  # 移动音频文件到 Music
  cp -rf $workPath/stay.mp3 $HOME/Music
  # 移动 compton 配置文件到 ~/.config
  cp -rf $workPath/compton/compton.conf $HOME/.config/
  # 添加并配置 xbindkeys 配置文件
  cp -rf $workPath/.xbindkeysrc $HOME
  # 添加并配置 xfce4 terminal 和 thunar 等配置
  cp -rf $workPath/xfce4 $HOME/.config
  # 添加并配置通知主题配置文件
  # cp -rf $workPath/xfce4-notifyd-theme.rc $HOME/.cache
  # 设置通知主题字体
  # sudo sed -i '30 afont_name = "STXingkai 12"' /usr/share/themes/OSX-Arc-Shadow/xfce-notify-4.0/gtkrc
  # sudo sed -i "31 s/^/  / " /usr/share/themes/OSX-Arc-Shadow/xfce-notify-4.0/gtkrc
  # sudo sed -i '43 s/Bold/STXingkai 14/g' /usr/share/themes/OSX-Arc-Shadow/xfce-notify-4.0/gtkrc
  # 添加并配置 i3 配置文件
  # mv $HOME/.config/i3/config $HOME/.config/i3/config.bak
  cp -rf $workPath/i3config/* $HOME/.config/i3/
  # 添加并配置 Polybar 配置文件
  cp -rf $workPath/polybarconf/* $HOME/.config/polybar/
  # qt4 配置文件
  cp -rf $workPath/qt4Config/* $HOME/.config
  # 添加并配置 GTK 主题配置
  cp -rf $workPath/gtk-2.0 $HOME/.config
  cp -rf $workPath/gtk-3.0 $HOME/.config
  cp -rf $workPath/.gtkrc-2.0 $HOME
  # 对于一些GUI程序无法弹出需要 gksudo的窗口,这或许会有用
  sudo sed -i '4 asession required pam_loginuid.so' /etc/pam.d/lightdm
  sudo sed -i '5 asession required pam_systemd.so' /etc/pam.d/lightdm
}

function main() {
  #statements
  # 安装需要的软件
  installApplications
  # 安装其他需要的软件
  someNeedsApplications
  # 安装 LightdmWebKit2 和 主题
  installLightdmWebKit2
  # 安装 Grub2 主题
  installGrub2Themes
  # 安装 OSX-arc GTK 主题
  installOsxArcThemes
  # 安装 OhMyZsh
  installOhMyZsh
  # 配置DNS
  configDNS
  # 安装字体
  installFonts
  # 编译安装 ProxyChains-ng
  installProxyChains
  # 安装并配置 Shadowsocksr-Python
  installShadowsocksr
  # 编译安装 i3Gaps
  installI3Gaps
  # 编译安装 Polybar
  installPolybar
  # 安装 MPD , NCMPCPP
  installMpdNcmpcpp
  # 安装 VimPlus
  installVimPlus
  # 其他配置
  someConfigure
  # 清理临时目录
  sudo rm -rf $workPath/.cache
  # 安装蓝牙驱动
  installBluetooth
}

main
