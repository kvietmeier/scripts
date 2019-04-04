#!/bin/bash -x

# Variables
VPN_GATEWAY=$1
IFACE=$2

# Is vpnmod already running?  If not - start it
if [[ ! $(/sbin/lsmod | grep vpn | awk '{print $1}') ]]
   then /etc/init.d/vpn start
fi 

# Need the correct resolver libraries
#cp /etc/resolv.conf /etc/resolv.bak
#cp /etc/resolv.swan /etc/resolv.conf

# Open the tunnel
xterm -geometry 70x5+0+0 -title VPN -e /usr/local/bin/open_tunnel -d ${IFACE} -n vpn-${VPN_GATEWAY}.sun.com kv82579@vpn &
