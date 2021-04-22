#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo -E swupd bundle-add kvm-host
sudo -E systemctl restart libvirtd
sudo -E systemctl enable libvirtd

if sudo -E virsh net-list | grep -q nat; then
	sudo -E virsh net-destroy nat
	sudo -E virsh net-undefine nat
fi
sudo -E virsh net-define "$SCRIPT_DIR/nat.xml"
sudo -E virsh net-start nat
sudo -E virsh net-autostart nat

if [ -n "$1" ]; then
	sudo -E usermod -a -G libvirt "$1"
fi
