#!/bin/bash

apt-get update
apt-get install --no-install-recommends ca-certificates unzip vim wget curl net-tools snapd -y 
curl https://rclone.org/install.sh | bash 
snap install oracle-cloud-agent --classic 
echo 'alias ll="ls -la"' >> ~/.bashrc 
echo 'alias vi="vim"' >> ~/.bashrc 
echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.bashrc 

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io -y

rclone version
docker -v

source ~/.bashrc

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
