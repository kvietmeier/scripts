#!/bin/bash

for i in $(ls -l /dev/disk/by-path | egrep 0f:00.0| grep -v part | awk '{print substr($11, 7)}' | sort)
  do 
      sdparm --get=WCE /dev/${i}
  done
