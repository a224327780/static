#!/bin/bash

apt-get update
apt-get install --no-install-recommends ca-certificates unzip vim wget curl locales ntp net-tools snapd -y 
curl https://rclone.org/install.sh | bash 
curl -fsSL https://get.docker.com | sh
snap install oracle-cloud-agent --classic 

KEY_PATH="$HOME/.ssh/id_rsa"
if [ -f "$KEY_PATH" ]; then
  echo "SSH key already exists at $KEY_PATH"
else
  echo -e "\n" | ssh-keygen -t rsa -b 2048 -N "" -f "$KEY_PATH"
  echo "SSH key generated at $KEY_PATH"
  cat >/root/.ssh/authorized_keys<<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi2k6GKNpgIpqadov6v5Rf6sKbiaGvklOwWE0SorIBr0cI6o/9lrIc1Bq5eqGOJr8lhvichGcdLhxjTPwDKa+lOMAe3HeUnP6jVvAA/1vBev9vTbSNKTY/osDV2YukNo8Tda+zhkioWzfKdpNHvBrnfsIdl22qjd74m14TbRaTQiY60xKd0ydjywbg45jFP2M6Pc7WRPiC1zPfvNaR16+LhlqzJuXROCI8QaUnHwprwh8gMs6yqvtTkzcQYaCaXd6rzYxb8jFtmCyj72qY7nAF0ED6VDw07QUyJAIyz+ybd+2d6w90wtJtkUBi5oPcyg2j/w+rU7yA5GNhsor+eZ19
EOF
  
fi

mkdir -p /data/shadowsocks-libev 
cat >/data/shadowsocks-libev/config.json<<EOF
{
    "server":"0.0.0.0",
    "server_port":9010,
    "password":"bVN2j2n3F2C3",
    "timeout":120,
    "method":"aes-256-gcm",
    "fast_open":true,
    "nameserver":"1.1.1.1",
    "mode":"tcp_and_udp"
}
EOF

dpkg-reconfigure --frontend=noninteractive locales
locale-gen zh_CN.UTF-8
sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

cat >~/.vimrc<<EOF
syntax on
set encoding=utf-8
set smartindent
set wrap
set ruler
EOF

echo 'alias ll="ls -la"' >> ~/.bashrc 
echo 'alias vi="vim"' >> ~/.bashrc 
echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export LC_ALL=zh_CN.UTF-8' >> ~/.bashrc 

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

cat >/etc/docker/daemon.json<<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

docker network create brg-net
docker run -d -p 9010:9010 -p 9010:9010/udp --name ss --network brg-net --network-alias ss --restart=always -v /data/shadowsocks-libev:/etc/shadowsocks-libev teddysun/shadowsocks-libev

cat <(crontab -l) <(echo "0 18,20,22 * * * root timeout 300 docker run --rm ghcr.io/a224327780/lookbusy lookbusy -c 10-30 -r curve -p 300 >/dev/null &") | crontab -

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
