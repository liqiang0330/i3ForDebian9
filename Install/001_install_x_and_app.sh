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
installCache

# 更换软件源为 ustc
print_dot
echo "Replace apt sources list to << USTC >> for china. And update upgrade Your system."
print_dot
wget -c https://mirrors.ustc.edu.cn/repogen/conf/debian-https-4-buster -O sources.list
sudo cp -rf sources.list /etc/apt/
sudo chmod 644 /etc/apt/sources.list
sudo chown root:root /etc/apt/sources.list
# 添加 Debiancn 源
echo "deb https://mirrors.ustc.edu.cn/debiancn/ testing main" | sudo tee /etc/apt/sources.list.d/debiancn.list
wget -c https://mirrors.ustc.edu.cn/debiancn/debiancn-keyring_0~20161212_all.deb -O debiancn-keyring.deb
sudo apt install debiancn-keyring.deb
sudo apt update && sudo apt -y upgrade
rm -rf sources.list
rm -rf debiancn-keyring.deb

# 安装需要的 x 环境
