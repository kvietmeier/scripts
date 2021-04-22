#!/bin/bash
sudo -E swupd bundle-add containers-basic
if [ ! -z "$1" ]; then
	sudo -E usermod -a -G docker "$1"
fi
sudo -E systemctl restart docker
sudo -E systemctl enable docker
