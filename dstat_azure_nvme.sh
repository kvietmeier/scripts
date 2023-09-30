#!/usr/bin/bash
###==========================================================================================================### 
#
#    Basic Usage: Run dstat and collect output into csv files.
#    Collect system profile while monitoring disk usage during benchmark runs or performance troubleshooting
#    Created By:   Karl Vietmeier
#                  Cloud Solutions Architect, Intel
#  
#    Written for an Azure Ubuntu VM with NVME controllers
#
###==========================================================================================================### 

#-- Functions
# Run cmd in background
bg_cmd()
  {
    cmd="$@"
    ${cmd} &>/dev/null &
    disown
  }

#-- End Functions

#-- Variables/Setup

# Enumerate the nvme drives
nvme_drives=($(ls -l /dev/disk/by-path | grep nvme | grep -v part | awk '{print substr($11, 7)}' | sort))
disks=$(IFS=,; echo "${nvme_drives[*]}")

# Setup directories/output files
CURRENT_TIME=$(date +%m%d:%H%M)
OUTPUTDIR=${HOME}/dstat/

# Check if the directory for output exists
if [ ! -d $OUTPUTDIR ] ; then
  mkdir $OUTPUTDIR 2> /dev/null
fi

OUTPUTFILE_proc=${OUTPUTDIR}dstat_process.${CURRENT_TIME}.csv
OUTPUTFILE_io=${OUTPUTDIR}dstat_io.${CURRENT_TIME}.csv
OUTPUTFILE_sys=${OUTPUTDIR}dstat_sys.${CURRENT_TIME}.csv

# Command intervals
sinterval=1
minterval=10
linterval=30
llinterval=3600
count=380

# dstat flags
dstat_io_flags="-D total,$disks -N eth0"
dstat_proc_flags="--time -p -c --disk --mem --top-cpu --top-bio --top-latency "
dstat_sys_flags="--time --load --proc --cpu --sys --vm --disk  --net -N eth0"

dstat_io="dstat $dstat_io_flags --output $OUTPUTFILE_io $linterval $count"
dstat_process="dstat $dstat_proc_flags --output $OUTPUTFILE_proc $linterval $count"
dstat_sys="dstat $dstat_sys_flags --output $OUTPUTFILE_sys $linterval $count"


#-- Main 
bg_cmd ${dstat_process}
bg_cmd ${dstat_disk}
bg_cmd ${dstat_sys}

