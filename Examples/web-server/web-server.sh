#!/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
sudo -E swupd bundle-add web-server-basic
sudo -E mkdir -p /etc/nginx/conf.d
sudo -E cp -f /usr/share/nginx/conf/nginx.conf.example /etc/nginx/nginx.conf
sudo -E cp -f "$SCRIPT_DIR"/default.conf /etc/nginx/conf.d
sudo -E systemctl restart nginx
sudo -E systemctl enable nginx
