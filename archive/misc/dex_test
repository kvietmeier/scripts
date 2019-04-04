#!/bin/ksh

DEXDIR=$(pwd)
CDIR=$(pwd)
DISKS=$1

if [ -e ${CDIR}/dex ]
	then
		${CDIR}/dex -v -RI256 3g 0  -x 64k -eh 5 1 -p 16 -w/r -PB 0x7e /dev/rdsk/${DISKS} &
	else
		echo "Can't Find Dex - trying $DEXDIR"
		${DEXDIR}/dex -v -RI256 3g 0  -x 64k -eh 5 1 -p 16 -w/r -PB 0x7e /dev/rdsk/${DISKS} &
fi
