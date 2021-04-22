#!/bin/bash
sudo -E mkdir -p /etc/systemd/system/docker.service.d
sudo -E tee /etc/systemd/system/docker.service.d/proxy.conf > /dev/null <<- EOF
[Service]
Environment="HTTP_PROXY=http://proxy-chain.intel.com:911"
Environment="HTTPS_PROXY=http://proxy-chain.intel.com:912"
Environment="NO_PROXY=localhost,intel.com,0.0.0.0/8,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16,224.0.0.0/4,240.0.0.0/4"
EOF
sudo -E systemctl restart docker
