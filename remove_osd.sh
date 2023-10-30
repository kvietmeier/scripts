#!/bin/bash

echo -n "Finding host.. "
remosd=$1
remhost=$(ceph osd find $remosd 2>/dev/null | grep host | awk '{print $4}' | sed -e s/[\",]//g)
if [ "$remhost"x == ""x ]; then
	echo Failed: osd.$remosd does not exist.
else
	echo $remhost
# to-do:  have remhost echo the /dev/sdXXX device being unmounted, for future reference.
# to-do:  have remhost set the typecodes on the partitions to 89c57f98-2fe5-4dc0-89c1-f3ad0ceff2be.  This and the umount should perhaps be done in a subshell or
#         something in case they hang
	echo "Setting noscrub, nodeep-scrub"
	ssh $remhost -- "echo -n 'Stopping osd.$remosd: '; stop ceph-osd id=$remosd; echo -n 'Removing upstart flag: '; rm -f /var/lib/ceph/osd/ceph-$remosd/upstart; echo done; remdrive=\$(mount | grep \"ceph-$remosd \" | awk '{print \$1}'); echo -n \"Umounting $remdrive: \"; umount \$remdrive; echo done; echo -n \"Removing mount point\"; rmdir /var/lib/ceph/osd/ceph-$remosd; echo done"
	echo -n "Removing CRUSH entry for osd.$remosd: "
	ceph osd crush remove osd.$remosd
	echo -n "Removing OSD entry for osd.$remosd: "
	ceph osd rm osd.$remosd
	echo -n "Removing Auth for osd.$remosd: "
	ceph auth del osd.$remosd
	echo "Please run 'ceph -w' or 'watch ceph -s' to monitor for rebalancing to complete, then 'ceph osd unset noscrub; ceph osd unset nodeep-scrub'"
fi

# Reference:  the typecodes that Ceph uses.

#JOURNAL_UUID =         '45b0969e-9b03-4f30-b4c6-b4b80ceff106'
#DMCRYPT_JOURNAL_UUID = '45b0969e-9b03-4f30-b4c6-5ec00ceff106'
#OSD_UUID =             '4fbd7e29-9d25-41b8-afd0-062c0ceff05d'
#DMCRYPT_OSD_UUID =     '4fbd7e29-9d25-41b8-afd0-5ec00ceff05d'
#TOBE_UUID =            '89c57f98-2fe5-4dc0-89c1-f3ad0ceff2be'
#DMCRYPT_TOBE_UUID =    '89c57f98-2fe5-4dc0-89c1-5ec00ceff2be'