#!/bin/bash
if [ -n "$1" ]; then
	sudo -E swupd bundle-add sysadmin-basic
	sudo -E timedatectl set-timezone "$1"
fi
sudo -E mkdir -p /etc/systemd
sudo -E tee /etc/systemd/timesyncd.conf > /dev/null <<- EOF
[Time]
NTP=corp.intel.com
FallbackNTP=time.nist.gov
EOF
sudo -E timedatectl set-ntp true
sudo -E systemctl restart systemd-timesyncd
