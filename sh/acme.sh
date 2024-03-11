#!/bin/bash

ACMESH="~/.acme.sh/acme.sh"
DOMAIN_LIST=`$ACMESH --list | awk '{print $1}' | grep -v 'Main_Domain'`

applyFreeSSLCertificate(){
    status=0
    $ACMESH --cron --home "/root/.acme.sh" --force
    [ $? -eq 0 ] && status=`expr $status + 1`
    # 2、安装ssl证书到nginx
    $ACMESH --install-cert -d ${domain} --key-file "/data/nginx/conf/ssl/${domain}/${domain}.key" --fullchain-file "/data/nginx/conf/ssl/${domain}/fullchain"
    [ $? -eq 0 ] && status=`expr $status + 1`

    if [ $status -eq 2 ];then
      echo "续期（提前一周）免费ssl证书${domain}成功！"
    else
      echo "续期（提前一周）免费ssl证书${domain}失败！"
    fi
}

# 自动续期
for domain in $DOMAIN_LIST;do

  # 检查ssl证书到期时间，提前一周自动续期并部署新的ssl证书
  expirationTimeGMT=`openssl x509 -in ~/.acme.sh/${domain}_ecc/${domain}.cer -noout -dates|grep notAfter|awk -F '=' '{print $2}'`
  # 证书到期时间，转换为以秒为单位的时间戳
  expirationTime=`date -d "$expirationTimeGMT" +%s`
  # 当前时间戳
  currTime=`date +%s`

  echo "域名=${domain}; 证书到期时间还有$(expr $(expr $expirationTime - $currTime) / 60 / 60 / 24)天"
  if [ $(expr $(expr $expirationTime - $currTime) / 60 / 60 / 24) -lt 7 ];then
    applyFreeSSLCertificate
    container_id=`docker ps -a |grep nginx | awk '{print $1}'`
    docker exec ${container_id} nginx -s reload
  fi
done