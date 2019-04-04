#!/bin/ksh
#
#  Restart all the daemons needed for jumpstart to flush the arp 
#  cache and refresh the nfs shares
#

# Pretty simple to start with - just run the various commands
echo "Unshare everthing"
echo " unshareall"
unshareall

echo "Stop nfs"
echo "/etc/init.d/nfs.server stop"
/etc/init.d/nfs.server stop

echo "Kill rarpd"
echo "pkill in.rarpd"
pkill in.rarpd

echo "Start everything up again"
echo "/usr/sbin/in.rarpd -a"
echo "/etc/init.d/nfs.server start"
echo "shareall"
/usr/sbin/in.rarpd -a
/etc/init.d/nfs.server start
shareall
