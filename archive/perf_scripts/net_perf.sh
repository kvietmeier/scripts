#!/bin/ksh  
# This module collects netstat information for each plumbed
# interface, in Solaris 8 and 9 we grab kstat info too.
# 
# Last Modified:
# 06/26/03  Karl Vietmeier
#  Cleaned up indenting, removed tabs etc
#  Changed header information


NETCOUNT=`expr $COUNT - 3`
# just a counter
X=0

# How long should I wait for each time through the while?
(( SLEEP_INTERVAL = $NETCOUNT * $NETINTERVAL ))

while [ $X != $ITERATIONS ];
 do
   # For 2.6 and above
   OSBASE=`uname -r`
   if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ] || [ "$OSBASE" = "5.6" ]; 
     then
         # Get data for each active interface
         for i in $(netstat -i | awk '{print $1}')
           do
             if [[ $i = "Name" ]]
                then continue
                else NETSTAT_OUTFILE=${LOGDIR}/netstat_i_${i}.$$	
                     echo "" >> $NETSTAT_OUTFILE
                     date >> $NETSTAT_OUTFILE
                     netstat -i -I $i $NETINTERVAL $NETCOUNT >> $NETSTAT_OUTFILE  &

                     # Check for 8 and 9 - then run kstat too
                     if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.9" ];
                       then KSTAT_OUTFILE=${LOGDIR}/kstat_${i}.$$	
                            echo "" >> $KSTAT_OUTFILE
                            date >> $KSTAT_OUTFILE
                            kstat -n $i >> $KSTAT_OUTFILE
                     fi
             fi
           done

      else exit
   fi

   sleep $SLEEP_INTERVAL
   X=`expr $X + 1`
 done

