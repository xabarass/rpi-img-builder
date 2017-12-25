#!/bin/bash

# This script is used to extend fs in img file.
# This is necessary in order to make all SCION files fit in image file

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

img_file=$1

dd if=/dev/zero bs=1M count=1024 >> "$img_file"

partitions=$(parted "$img_file" print free)

extend_size=$(echo "$partitions" | awk 'END {print $(NF-3)}' | sed -r "s/([0-9]+)MB/\1/g") 

parted "$img_file" resizepart 2 "$extend_size"

kparted_out=$(kpartx -a -v "$img_file")

loop_dev_name=$(echo "$kparted_out" | awk 'END {print $(3)}' )

# Timing issue :/
sleep 2

sudo e2fsck -f -y "/dev/mapper/$loop_dev_name"
sudo resize2fs "/dev/mapper/$loop_dev_name"

sleep 2

echo "$loop_dev_name"