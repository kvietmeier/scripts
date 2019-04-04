#!/bin/ksh  

# The following script (or something very similiar) should be ran on any 
# critical system over a period of time to help build a "profile" of 
# system usage to help determine normal loads.

while [ TRUE ];
do
	echo "" >> $NFS_OUTFILE
        date >> $NFS_OUTFILE
        /usr/bin/nfsstat -cs >> $NFS_OUTFILE 
        /usr/bin/nfsstat -m >> $NFS_OUTFILE 

sleep 60	

done
