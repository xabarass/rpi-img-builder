UNAME ?= scion
UPASS ?= scion
RPASS ?= raspberry
LOCALE ?= en_US.UTF-8
INC_REC ?= 0

EXPORT_DIR := /home/scion/export
BASE_DIR := $(shell pwd)
ROOTFS_DIR := $(EXPORT_DIR)/rootfs

THIS_IP := 10.10.10.2
DEVICE_MOUNT := /nfs/host_export
DEVICE_MOUNT_ROOTFS := $(DEVICE_MOUNT)/rootfs
DEVICE_IP := 10.10.10.42
DEVICE_USER := root

TIMESTAMP := $(shell date +'%Y-%m-%dT%H:%M:%S')

