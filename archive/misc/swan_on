#!/bin/ksh
# Start the VPN service

echo "$1"
echo ""

opt=$1
gtwy=vpn-${opt}

STATUS=$(ps -ef | grep open_tunnel | grep -v grep)

xterm -title VPN -geometry 73x7+770+0 -e /usr/local/bin/open_tunnel -d hme0 -n ${gtwy} kv82579@vpn &
