#!/bin/bash

apt-get update
apt-get install --no-install-recommends ca-certificates git unzip vim wget curl net-tools snapd python3 python3-distutils -y 
curl https://rclone.org/install.sh | bash 
rclone --version
curl https://get.acme.sh | sh -s email=atcaoyufei@gmail.com 
curl -L https://fly.io/install.sh | sh
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py
pip3 install --no-cache-dir requests pyquery motor python-dotenv redis aioredis rsa aiohttp
snap install oracle-cloud-agent --classic 
echo 'alias ll="ls -la"' >> ~/.bashrc 
echo 'alias vi="vim"' >> ~/.bashrc 
echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.bashrc 
echo 'export CLOUDFLARE_API_TOKEN=""' >>~/.bashrc 
echo 'export CLOUDFLARE_ACCOUNT_ID=""' >>~/.bashrc
echo 'export FLYCTL_INSTALL="/root/.fly"' >> ~/.bashrc
echo 'export PATH="$FLYCTL_INSTALL/bin:$PATH"' >> ~/.bashrc

export PNPM_HOME="/root/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if command -v pnpm >/dev/null 2>&1; then
  pnpm env use 16 --global 
  pnpm add -g wrangler
  wrangler --version
fi

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

cat >~/.gitconfig<<EOF
[user]
        name = atcaoyufei
        email = atcaoyufei@gmail.com
[pull]
        rebase = false
EOF

source ~/.bashrc

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
