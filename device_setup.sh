#!/usr/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 THIS_IP EXPORT_DIR DEVICE_MOUNT"
    exit 1
fi

set -e

THIS_IP=$1
EXPORT_DIR=$2
DEVICE_MOUNT=$3

echo "Mounting NFS filesystem from $THIS_IP to $DEVICE_MOUNT"

mkdir -p $DEVICE_MOUNT
mount $THIS_IP:$EXPORT_DIR $DEVICE_MOUNT

echo "Done."
