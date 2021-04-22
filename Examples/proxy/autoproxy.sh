#!/bin/bash
sudo -E mkdir -p /etc/systemd
sudo -E tee /etc/systemd/resolved.conf > /dev/null <<- EOF
[Resolve]
Domains=intel.com jf.intel.com ostc.intel.com
EOF
sudo -E systemctl restart systemd-resolved

if [ -z "$(ls -A /run/systemd/netif/leases)" ]; then
	sudo -E systemctl restart pacdiscovery.service
	sudo -E systemctl enable pacdiscovery.service
fi

MAX_SECONDS=15
SECONDS=0
while [ "$SECONDS" -le "$MAX_SECONDS" ] && [ ! -e /run/pacrunner/pac_active ]; do
	sleep 1s
done
