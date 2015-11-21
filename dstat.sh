#!/bin/bash
#  Run dstat and collect output into csv files.
#  Collect system profile, summarizing system state

#-- Functions
# Run cmd in background
bg_cmd()
  {
    cmd="$@"
    ${cmd} &>/dev/null &
    disown
  }

#-- End Functions

#-- Variables
CURRENT_TIME=$(date +%m%d:%H%M)
OUTPUTDIR="/root/output/"
OUTPUTFILE_PROC=${OUTPUTDIR}dstat_process.${CURRENT_TIME}.csv
OUTPUTFILE_SYS=${OUTPUTDIR}dstat_sys.${CURRENT_TIME}.csv

# Command intervals
sinterval=1
minterval=10
linterval=30
llinterval=3600
count=380

dstat_proc_flags="--time -p -c --disk --mem --top-cpu --top-bio --top-latency "
dstat_sys_flags="--time --load --proc --cpu --sys --vm --disk  --net -N bond0,bond1"

dstat_process="dstat $dstat_proc_flags --output $OUTPUTFILE_PROC $linterval $count"
dstat_sys="dstat $dstat_sys_flags --output $OUTPUTFILE_SYS $linterval $count"

#-- Main 
bg_cmd ${dstat_process}
bg_cmd ${dstat_sys}

