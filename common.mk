UNAME ?= scion
UPASS ?= scion
RPASS ?= raspberry
LOCALE ?= en_US.UTF-8
INC_REC ?= 0

BASE_DIR := $(shell pwd)
ROOTFS_DIR := /tmp/rootfs

TIMESTAMP := $(shell date +'%Y-%m-%dT%H:%M:%S')

QEMU := qemu-arm-static
