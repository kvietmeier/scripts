#!/bin/bash
# Prepare data drives for use 

for i in {0..5}
do
  # Drives index on 0, volumes on 1
  j=$((i+1))

  # Run parted
  parted -s -a optimal /dev/nvme${i}n1 mklabel gpt
  parted -s -a optimal /dev/nvme${i}n1 mkpart primary xfs 0% 100%
  parted -s /dev/nvme${i}n1 name 1 "minio-data${j}"

  sleep 3
  echo ""
  mkfs.xfs -f /dev/nvme${i}n1p1  > /dev/null 2>&1

  mkdir -p /mnt/data_disk${j}
  mount /dev/nvme${i}n1p1 /mnt/data_disk${j}
  echo ""

done
