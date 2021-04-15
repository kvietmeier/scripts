#!/bin/bash
# Close the tunnel and stop vpn

/usr/local/bin/close_tunnel
/etc/init.d/vpn stop
cp /etc/resolv.bak /etc/resolv.conf
