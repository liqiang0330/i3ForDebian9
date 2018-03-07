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
  sudo apt -y install lightdm i3 git vim neofetch feh resolvconf fonts-wqy-zenhei lxappearance gdebi qt4-qtconfig compton curl wget ranger volumeicon-alsa pulseaudio pavucontrol fonts-arphic-uming arandr xdg-utils wpasupplicant wpagui htop p7zip-full xfce4-terminal xfce4-notifyd zsh xfce4-power-manager* thunar breeze-cursor-theme file-roller pulseaudio-module-bluetooth blueman rofi xbindkeys zsh-syntax-highlighting scrot imagemagick zathura*
}

function installFonts() {
  #statements
  # 安装简繁体中文支持
  sudo apt -y install language-pack-zh-hans language-pack-zh-hant
  # 安装字体以及字体配置
  bash $workPath/fonts/fonts-master/install.sh
  sudo cp -rf $workPath/fonts/noto* /usr/share/fonts/truetype/
  sudo cp -rf $workPath/fonts/66-noto* /etc/fonts/conf.avail/
  wget -c https://raw.githubusercontent.com/ohmyarch/fontconfig-zh-cn/master/fonts.conf
  mkdir -p $HOME/.config/fontconfig
  mkdir -p $HOME/.local/share/fonts
  cp -rf fonts.conf $HOME/.config/fontconfig
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
  sudo fc-cache --force --verbose
  sudo dpkg-reconfigure locales
  sudo sed -i 's/LANGUAGE="en_US:en"/LANGUAGE="zh_CN"/g' /etc/default/locale
  installCache
}
function someNeedsApplications() {
  #statements
  installCache
  # 安装 fcitx 输入法支持
  sudo apt -y install fcitx  fcitx-data fcitx-frontend-qt4  fcitx-libs-qt  fcitx-module-x11 fcitx-bin fcitx-frontend-all  fcitx-frontend-qt5 fcitx-table fcitx-config-common fcitx-frontend-fbterm  fcitx-libs  fcitx-module-dbus  fcitx-table-wubi fcitx-config-gtk  fcitx-frontend-gtk2   fcitx-libs-dev   fcitx-module-kimpanel  fcitx-ui-classic fcitx-config-gtk2  fcitx-frontend-gtk3   fcitx-modules
  # 安装 telegram , Chrome , sogoupinyin , Atom , VSCode
  sudo apt -y telegram-desktop google-chrome-stable sogoupinyin atom code
  # vim 常用功能
  cat <<VIM_CONF | tee $HOME/.vimrc
  set nocompatible
  set nu!
  syntax on
  set autoindent
  set tabstop=4
  set ai!
  set history=1000
  filetype on
  set nocompatible
  set ruler
  set incsearch
  set showmatch
VIM_CONF
  # 添加 DNS
  cat <<DNS_RESOLV_CONF | sudo tee /etc/resolvconf/resolv.conf.d/head
  nameserver 223.5.5.5
  nameserver 223.6.6.6
  nameserver 114.114.114.114
DNS_RESOLV_CONF
  sudo resolvconf -u &&  sudo resolvconf --enable-updates
  # 卸载 dunst ,因为它与 xfce4-notifyd 会发生冲突
  # 卸载NetworkManager
  sudo apt -y purge dunst notification-daemon network-manager network-manager-gnome
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
  # sudo sed -i 's/unity-greeter/lightdm-webkit2-greeter/g' /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf

  # 更换"lightdm-webkit2-greeter"主题为aether
  sudo git clone https://github.com/NoiSek/Aether.git /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
  sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf

  # 对于一些GUI程序无法弹出需要 gksudo的窗口,这或许会有用
  sudo sed -i '4 asession required pam_loginuid.so' /etc/pam.d/lightdm
  sudo sed -i '5 asession required pam_systemd.so' /etc/pam.d/lightdm

  # 更改Grub2主题
  sudo mkdir -p /boot/grub/themes
  sudo cp -rf $workPath/grub2-themes/* /boot/grub/themes
  sudo grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"/boot/grub/themes/Vimix/theme.txt\"" | sudo tee -a /etc/default/grub
  sudo update-grub

  # 安装ohmyzsh
  cd $HOME
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  # 安装zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  # 更改默认shell为zsh
  chsh -s /usr/bin/zsh
}
# 安装需要的软件
installApplications
# 生成 XDG_HOME_CONFIG
xdg-user-dirs-update
# 安装和配置需要设置的东西
someNeedsApplications
installLightdmWebKit2
# 安装字体
installFonts
