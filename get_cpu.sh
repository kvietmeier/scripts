#!/usr/bin/bash
# Get CPU type from hosts
# 

for i in {2..5}
do  	
  cpu=$(ssh ubuntu@vdb-0$i "cat /proc/cpuinfo | sed -n -E '/^model\s*(name|)\s*:/{s/.*:\s*//;p}' | head -n2 | tr '\n\n' ':'")
  echo "vdb-0$i:  $cpu"
done
