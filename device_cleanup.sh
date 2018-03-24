#!/usr/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DEVICE_MOUNT_ROOTFS"
    exit 1
fi

set -e

DEVICE_MOUNT_ROOTFS=$1

echo "Running device cleanup for $DEVICE_MOUNT_ROOTFS"

if mountpoint -q $DEVICE_MOUNT_ROOTFS/proc; then \
    umount $DEVICE_MOUNT_ROOTFS/proc; \
fi
if mountpoint -q $DEVICE_MOUNT_ROOTFS/sys; then \
    umount $DEVICE_MOUNT_ROOTFS/sys; \
fi
if mountpoint -q $DEVICE_MOUNT_ROOTFS/dev; then \
    umount $DEVICE_MOUNT_ROOTFS/dev; \
fi

echo "Cleanup complete"