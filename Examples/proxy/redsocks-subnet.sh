#!/bin/bash
sudo -E iptables -t nat -A PREROUTING -i "$1" -j PROXY
sudo -E systemctl restart iptables-save
sudo -E systemctl restart iptables-restore
sudo -E tee -a /etc/redsocks.conf > /dev/null <<- EOF
redsocks {
	local_ip = $2;
	local_port = 1080;
	ip = proxy-us.intel.com;
	port = 1080;
	type = socks5;
}
EOF
sudo -E systemctl restart redsocks
