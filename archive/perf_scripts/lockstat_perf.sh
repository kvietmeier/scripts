#!/bin/ksh  


# The following script (or something very similiar) should be ran on any 
# critical system over a period of time to help build a "profile" of 
# system usage to help determine normal loads.




# just a counter
LSINTERVAL=30


if [ ! -d $LOGDIR ]; then
	mkdir $LOGDIR
fi



while [ TRUE ];do
	echo "" >> $LOCKSTAT_OUTFILE
        date >> $LOCKSTAT_OUTFILE

# for 2.6 and above
	if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ] || [ "$OSBASE" = "5.6" ]; then
       	 	/usr/sbin/lockstat -H -s 10 -D 15 sleep 60 1>> $LOCKSTAT_OUTFILE 2>/dev/null 
       		echo "" >> $LOCKSTAT_OUTFILE
	else
		echo "lockstat not available for OS" >> $LOCKSTAT_OUTFILE
		exit 
	fi


	sleep $LSINTERVAL
done

