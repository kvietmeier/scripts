#!/bin/ksh  
# This module collects basic kernel parameters and statistics
#  (need to add check for patch level/OS version)
# Last Modified:
#   06/26/03  Karl Vietmeier
#    Cleaned up syntax and indenting
#    Changed header information

kma_stats()
{
 echo "" >> $KMASTAT_OUTFILE
 date >> $KMASTAT_OUTFILE
 echo kmastat | crash >> $KMASTAT_OUTFILE
}

kernmap_stats()
{
 echo "" >> $KERNELMAP_OUTFILE
 echo "" >> $KERNELMAP_OUTFILE
 date >> $KERNELMAP_OUTFILE
 echo "map kernelmap" | crash >> $KERNELMAP_OUTFILE
}

kmem_stats()
{
 if [ "$ISE10K" = "SUNW,Ultra-Enterprise-10000" ]
   then echo "" >> $KERNEL_PARAMS_OUTFILE
        date >> $KERNEL_PARAMS_OUTFILE
        if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ]
          then for KPARAM in $E10K_NEWKMEM_PARAMS
                  do
                    echo $KPARAM >> $KERNEL_PARAMS_OUTFILE
                    echo $KPARAM\/E  | adb -k  >> $KERNEL_PARAMS_OUTFILE
                  done
          else echo "" >> $KERNEL_PARAMS_OUTFILE
               date >> $KERNEL_PARAMS_OUTFILE
               for KPARAM in $E10K_OLDKMEM_PARAMS
                  do
                    echo $KPARAM >> $KERNEL_PARAMS_OUTFILE
                    echo $KPARAM\/D  | adb -k  >> $KERNEL_PARAMS_OUTFILE
                  done
        fi

   else if [ "$OSBASE" = "5.8" ] || [ "$OSBASE" = "5.7" ]
        then echo "" >> $KERNEL_PARAMS_OUTFILE
             date >> $KERNEL_PARAMS_OUTFILE
             for KPARAM in $NONE10K_KMEM_PARAMS
                do
                  echo $KPARAM >> $KERNEL_PARAMS_OUTFILE
                  echo $KPARAM\/E  | adb -k  >> $KERNEL_PARAMS_OUTFILE
                done
        else echo "" >> $KERNEL_PARAMS_OUTFILE
             date >> $KERNEL_PARAMS_OUTFILE
             for KPARAM in $NONE10K_KMEM_PARAMS
                do
                  echo $KPARAM >> $KERNEL_PARAMS_OUTFILE
                  echo $KPARAM\/D  | adb -k  >> $KERNEL_PARAMS_OUTFILE
                done
        fi
 fi

}

ipc_stats()
{
 echo "" >> $IPCS_OUTFILE
 /usr/bin/ipcs -a >> $IPCS_OUTFILE
}

swap_stats()
{
 echo "" >> $SWAP_OUTFILE
 date >> $SWAP_OUTFILE
 /usr/sbin/swap -l >> $SWAP_OUTFILE
}


while [ TRUE ]
 do
  # Commented out due to SunAlert 27552
  #kma_stats
  #kmem_stats
  #kernmap_stats (broken)
  ipc_stats
  swap_stats
  sleep $KERNELSTAT_INTERVAL
 done



