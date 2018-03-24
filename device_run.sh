#!/usr/bin/env bash
set -e

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 DEVICE_MOUNT_ROOTFS LOCALE UNAME UPASS RPASS INC_REC"
    exit 1
fi

DEVICE_MOUNT_ROOTFS=$1
LOCALE=$2
UNAME=$3
UPASS=$4
RPASS=$5
INC_REC=$6

echo "Mounting necessary directories to $DEVICE_MOUNT_ROOTFS"

mkdir -p $DEVICE_MOUNT_ROOTFS/proc
mkdir -p $DEVICE_MOUNT_ROOTFS/sys
mkdir -p $DEVICE_MOUNT_ROOTFS/dev

mount -o bind /proc $DEVICE_MOUNT_ROOTFS/proc
mount -o bind /sys $DEVICE_MOUNT_ROOTFS/sys
mount -o bind /dev $DEVICE_MOUNT_ROOTFS/dev

echo "Chroot with arguments: LOCALE $LOCALE $UNAME $UPASS $RPASS $INC_REC"

chroot $DEVICE_MOUNT_ROOTFS /bin/bash -c "/postinstall $LOCALE $UNAME $UPASS $RPASS $INC_REC"

echo "Done building image on device. Exiting"

