#!/bin/bash

apt update && apt-get install -y locales ntpdate
sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
rm -rf /etc/localtime  

echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=zh_CN.UTF-8' >> ~/.bashrc
echo 'export SHELL=/bin/zsh' >>~/.bashrc
source ~/.bashrc

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.ubuntu.com