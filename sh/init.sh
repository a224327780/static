#!/bin/bash

apt-get update
apt-get install --no-install-recommends ca-certificates unzip vim wget curl locales ntpdate net-tools snapd -y 
curl https://rclone.org/install.sh | bash 
curl -fsSL https://get.docker.com | sh
snap install oracle-cloud-agent --classic 

dpkg-reconfigure --frontend=noninteractive locales
sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8

echo 'alias ll="ls -la"' >> ~/.bashrc 
echo 'alias vi="vim"' >> ~/.bashrc 
echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.bashrc 

# install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
# chmod a+r /etc/apt/keyrings/docker.asc

# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   tee /etc/apt/sources.list.d/docker.list > /dev/null
# apt-get update

# apt-get install docker-ce docker-ce-cli containerd.io -y

rclone version
# docker -v

source ~/.bashrc

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ntpdate ntp.ubuntu.com

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
