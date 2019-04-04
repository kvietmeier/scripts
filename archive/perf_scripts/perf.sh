#!/bin/ksh 

# HARDCODE DIRECTORY SETTING HERE
#export PERFDIR="/tmp"
export PERFDIRHOME=`dirname $0`
export HOST=$(uname -n)

# Suggestion for keeping everything in one place
export PERFDIR="${PERFDIRHOME}/runs"

# Last Mod	09-11-2001
# The following script (or something very similiar) should be ran on any 
# critical system over a period of time to help build a "profile" of 
# system usage to help determine normal loads.

# Last Mod 04/07/2003	
# Modified by Karl Vietmeier to add network stat gathering 
# and remove commands that call dev/kmem.

# ITERATIONS = number of times script will kick off prior to exit.   
# INTERVAL   = seconds
# COUNT      used to pretty up the output (keeps output consistant) 
# Each ITERATIONS at a INTERVAL of 2 seconds will gather ~40 seconds
# worth of performance data 
# So ITERATION of 40 is ~30 minutes.   

export ITERATIONS=40
export INTERVAL=2
export COUNT=19
export PSINTERVAL=60
export IOINTERVAL=10
export NETINTERVAL=10
export KERNELSTAT_INTERVAL=180
export PERFSECONDS=`expr $COUNT \* $ITERATIONS \* $INTERVAL` 


DATLOG=`date +%m_%d_%H:%M`
export LOGDIR=${PERFDIR}/${HOST}_${DATLOG}

if [ ! -d $LOGDIR ]; then
	mkdir -p $LOGDIR
fi

# output file names
NETSTAT_i_OUTFILE="$LOGDIR/netstat_all.$$"
NETSTAT_s_OUTFILE="$LOGDIR/netstat_s.$$"
NETSTAT_a_OUTFILE="$LOGDIR/netstat_a.$$"
MPSTAT_OUTFILE="$LOGDIR/mpstat.$$"
VMSTAT_OUTFILE="$LOGDIR/vmstat.$$"
PRTDIAG_OUTFILE="$LOGDIR/prtdiag_v.$$"
export KMASTAT_OUTFILE="$LOGDIR/kmastat.$$"
export KERNELMAP_OUTFILE="$LOGDIR/kernelmap.$$"
export KERNEL_PARAMS_OUTFILE="$LOGDIR/kernel_params.$$"
export IPCS_OUTFILE="$LOGDIR/ipcs_a.$$"
export SWAP_OUTFILE="$LOGDIR/swap_l.$$"
export KERNEL_PARAMS_OUTFILE="$LOGDIR/kernel_params.$$"
export IOSTAT_OUTFILE="$LOGDIR/iostat.$$"
export LOCKSTAT_OUTFILE="$LOGDIR/lockstat.$$"
export PSLOGDIR="$LOGDIR/ps_logs"
export NFS_OUTFILE="$LOGDIR/nfsstat.$$"

export OSBASE=`uname -r`
export ISE10K=`uname -i`
export E10K_OLDKMEM_PARAMS="freemem minfree lotsfree dr_kfreemem dr_kmaxfree"
export E10K_NEWKMEM_PARAMS="freemem minfree lotsfree kcage_desfree kcage_freemem kcage_lotsfree kcage_needfree kcage_minfree kcage_throttlefree"
export NONE10K_KMEM_PARAMS="freemem minfree lotsfree"


trap "killall" HUP INT QUIT KILL TERM USR1 USR2
killall()
{
PIDLIST="$NFS_PID $NET_PERFPID $PS_PERFPID $IO_PERFPID $LS_PERFPID $MPSTATPID $VMSTATPID $NETSTATPID $KERN_PID"
for PID in $PIDLIST
do
	kill -9 $PID 2>/dev/null
done
exit
}

###-----  Commands to run once per instance  -----###

#----- prtdiag -v 
# Check for E10K - 2.6 and below it is "sun4u1"
if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ]; then
		/usr/platform/sun4u/sbin/prtdiag -v >> $PRTDIAG_OUTFILE 
else
	if [ "$ISE10K" = "SUNW,Ultra-Enterprise-10000" ]; then
		/usr/platform/sun4u1/sbin/prtdiag -v >> $PRTDIAG_OUTFILE
	else
		/usr/platform/sun4u/sbin/prtdiag -v >> $PRTDIAG_OUTFILE
	fi
fi

###----- netstat data gathering
###----- to collect IPV6 info, remove "-f inet"
/usr/bin/netstat -sf inet > $NETSTAT_s_OUTFILE
/usr/bin/netstat -anf inet > $NETSTAT_a_OUTFILE


###-----  Run Modules  -----###
$PERFDIRHOME/ps_perf.sh &
PS_PERFPID=$!

$PERFDIRHOME/io_perf.sh &
IO_PERFPID=$!

$PERFDIRHOME/net_perf.sh &
NET_PERFPID=$!

$PERFDIRHOME/lockstat_perf.sh &
LS_PERFPID=$!

$PERFDIRHOME/kern_perf.sh &
KERN_PID=$!

$PERFDIRHOME/nfsstat.sh &
NFS_PID=$!


TIME=`expr $INTERVAL \* $COUNT`
TIMEPLUS=`expr $TIME + 5`

# just a counter
X=0
while [ $X != $ITERATIONS ]
do
	echo "" >> $MPSTAT_OUTFILE
   date >> $MPSTAT_OUTFILE
   mpstat $INTERVAL $COUNT >> $MPSTAT_OUTFILE &
	MPSTATPID=$!

	echo "" >> $VMSTAT_OUTFILE
   date >> $VMSTAT_OUTFILE
   vmstat  $INTERVAL $COUNT >> $VMSTAT_OUTFILE &
	VMSTATPID=$!

	echo "">> $NETSTAT_OUTFILE
   date >> $NETSTAT_OUTFILE
   #netstat -i $INTERVAL >> $NETSTAT_OUTFILE &
   NETSTATPID=$!


   #echo "sleeping for $TIMEPLUS"
   sleep $TIMEPLUS

	kill -9  $NETSTATPID

   X=`expr $X + 1`

done

PIDLIST="$NFS_PID $NET_PERFPID $PS_PERFPID $IO_PERFPID $LS_PERFPID $KERN_PID"
for PID in $PIDLIST
do
	kill -9 $PID 2>/dev/null
done

