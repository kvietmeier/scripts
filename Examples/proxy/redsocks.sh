#!/bin/bash
sudo -E swupd bundle-add network-basic
rm -rf intel-proxy-hack
git clone http://kojiclear.jf.intel.com/cgit/projects/intel-proxy-hack
(cd intel-proxy-hack
	sudo -E ./install.sh
	sudo -E tee /etc/redsocks.conf > /dev/null <<- EOF
	base {
		log_debug = off;
		log_info = off;
		log = stderr;
		daemon = off;
		redirector = iptables;
	}

	redsocks {
		local_ip = 127.0.0.1;
		local_port = 1080;
		ip = proxy-us.intel.com;
		port = 1080;
		type = socks5;
	}

	EOF
	sudo -E ./run.sh
)
rm -rf intel-proxy-hack
sudo -E systemctl restart iptables-save
sudo -E systemctl enable iptables-save
sudo -E systemctl restart iptables-restore
sudo -E systemctl enable iptables-restore

sudo -E rm -f /etc/profile.d/proxy.sh
