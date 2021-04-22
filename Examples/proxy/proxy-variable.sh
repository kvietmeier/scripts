#!/bin/bash
PROXY_FILE='/etc/profile.d/proxy.sh'
PROXY_URL='http://proxy-chain.intel.com'
NAMED_DOMAINS='localhost,intel.com'
SPECIALIZED_SUBNETS='0.0.0.0/8,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16,224.0.0.0/4,240.0.0.0/4'

sudo -E mkdir -p "$(dirname "$PROXY_FILE")"
sudo -E tee "$PROXY_FILE" > /dev/null <<- EOF
export http_proxy=$PROXY_URL:911
export https_proxy=$PROXY_URL:912
export ftp_proxy=$PROXY_URL:911
export socks_proxy=$PROXY_URL:1080
export rsync_proxy=$PROXY_URL:911
export no_proxy=$NAMED_DOMAINS,$SPECIALIZED_SUBNETS
EOF
echo "$PROXY_FILE"
