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
# 安装需要的软件
installApplications
# 生成 XDG_HOME_CONFIG
xdg-user-dirs-update
# 安装字体
installFonts
