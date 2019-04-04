#!/bin/ksh  
# The following script (or something very similiar) should be ran on any 
# critical system over a period of time to help build a "profile" of 
# system usage to help determine normal loads.

if [ ! -d $PSLOGDIR ]; then
	mkdir $PSLOGDIR
fi


while [ TRUE ];do
	PS_OUTFILE=$PSLOGDIR/ps_`date +%m_%d_%H:%M:%S`
	echo "" >> $PS_OUTFILE
        date >> $PS_OUTFILE
   # use if you need to SYS5 ps output 
	/usr/bin/ps -e -opid,ppid,class,s,psr,pri,nice,user,osz,wchan,vsz,pmem,pcpu,time,args >> $PS_OUTFILE 

   # use if you need to see wchan info and PPID
   #        /usr/ucb/ps -auxl >> $PS_OUTFILE 
   # use if you just want to see berkley PS output 
   #        /usr/ucb/ps -auxw >> $PS_OUTFILE 


	sleep $PSINTERVAL
done

