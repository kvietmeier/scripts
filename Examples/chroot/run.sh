#!/bin/bash
sudo -E systemd-nspawn --bind-ro=/var/cache/ca-certs --bind-ro=/etc/resolv.conf --directory="$1" "$2"
