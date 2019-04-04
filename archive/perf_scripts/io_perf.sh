#!/bin/ksh  

# The following script (or something very similiar) should be ran on any 
# critical system over a period of time to help build a "profile" of 
# system usage to help determine normal loads.


IOCOUNT=`expr $COUNT - 3`
# just a counter
X=0
while [ $X != $ITERATIONS ]; do
        echo "" >> $IOSTAT_OUTFILE
        date >> $IOSTAT_OUTFILE

# for 2.6 and above
OSBASE=`uname -r`
if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ] || [ "$OSBASE" = "5.6" ]; then

#  Get data for each partition
#        iostat -xpn $IOINTERVAL $IOCOUNT >> $IOSTAT_OUTFILE 
#  Get data for entire disk (no partitions)
        iostat -xn $IOINTERVAL $IOCOUNT >> $IOSTAT_OUTFILE 
else

# for prior to 2.6
        iostat -x $IOINTERVAL $IOCOUNT >> $IOSTAT_OUTFILE 
fi

        X=`expr $X + 1`
done

