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
  sudo apt -y install lightdm i3 git vim neofetch feh resolvconf fonts-wqy-zenhei lxappearance gdebi qt4-qtconfig compton curl wget ranger volumeicon-alsa pulseaudio pavucontrol fonts-arphic-uming arandr xdg-utils wpasupplicant wpagui htop p7zip-full xfce4-terminal xfce4-notifyd zsh xfce4-power-manager* thunar breeze-cursor-theme file-roller pulseaudio-module-bluetooth blueman rofi xbindkeys zsh-syntax-highlighting scrot imagemagick zathura* notify-osd
}

function someNeedsApplications() {
  #statements
  # 安装 fcitx 输入法支持
  sudo apt -y install fcitx fcitx-data fcitx-frontend-qt4 fcitx-libs-qt fcitx-module-x11 fcitx-bin fcitx-frontend-all fcitx-frontend-qt5 fcitx-table fcitx-config-common fcitx-frontend-fbterm fcitx-libs fcitx-module-dbus fcitx-table-wubi fcitx-config-gtk fcitx-frontend-gtk2 fcitx-libs-dev fcitx-module-kimpanel fcitx-ui-classic fcitx-config-gtk2 fcitx-frontend-gtk3 fcitx-modules
  # 安装 telegram , Chrome , sogoupinyin , Atom , VSCode
  sudo apt -y update
  sudo apt -y install telegram-desktop google-chrome-stable sogoupinyin atom code numix-gtk-theme numix-icon-theme
  # 卸载 dunst ,因为它与 xfce4-notifyd 会发生冲突
  # 卸载 NetworkManager
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
  sudo sed -i '/#greeter-session=example-gtk-gnome/agreeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
  # 更换"lightdm-webkit2-greeter"主题为aether
  sudo git clone https://github.com/NoiSek/Aether.git /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
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
  print_dot
  echo "Fonts installed , Updating font cache . "
  print_dot
  sudo fc-cache --force --verbose
  sudo dpkg-reconfigure locales
  sudo sed -i 's/LANGUAGE="en_US:en"/LANGUAGE="zh_CN"/g' /etc/default/locale
  installCache
}

function someConfigure() {
  #statements
  # vim 常用功能
  echo "Configure VIM"
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

  # 生成 XDG_HOME_CONFIG
  xdg-user-dirs-update
  # 更改默认shell为zsh
  chsh -s /usr/bin/zsh
  cp -rf $workPath/.zshrc $HOME
  # 移动壁纸到家目录
  cp -rf $workPath/.wallpaper.png $HOME
  # 移动头像到家目录
  cp -rf $workPath/.face $HOME
  # 移动音频文件到 Music
  cp -rf $workPath/stay.mp3 $HOME/Music
  # 移动 compton 配置文件到 ~/.config
  cp -rf $workPath/compton/compton.conf $HOME/.config/
  # 添加 xbindkeys 配置文件
  cp -rf $workPath/.xbindkeysrc $HOME
  # 添加 xfce4 terminal 和 thunar 等配置
  cp -rf $workPath/xfce4 $HOME/.config
  # 添加通知主题配置文件
  cp -rf $workPath/xfce4-notifyd-theme.rc $HOME/.cache
  # 对于一些GUI程序无法弹出需要 gksudo的窗口,这或许会有用
  sudo sed -i '4 asession required pam_loginuid.so' /etc/pam.d/lightdm
  sudo sed -i '5 asession required pam_systemd.so' /etc/pam.d/lightdm

}

# 安装需要的软件
installApplications
# 安装其他需要的软件
someNeedsApplications
# 安装 LightdmWebKit2 和 主题
installLightdmWebKit2
# 安装 Grub2 主题
installGrub2Themes
# 安装 OhMyZsh
installOhMyZsh
# 配置DNS
configDNS
# 安装字体
installFonts
# 其他配置
someConfigure
