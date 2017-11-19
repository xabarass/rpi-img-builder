DIST ?= stretch
REPO ?= Raspbian
RPI ?= 2
DIST_ARCH ?= armhf
ARCH ?= rpix
UNAME ?= scion
UPASS ?= scion
RPASS ?= raspberry
LOCALE ?= en_US.UTF-8
IMAGE_MB ?= 6100
BOOT_MB ?= 128
INC_REC ?= 0

FDIST := stretch
REPOBASE := Raspbian
REPOS := $(REPO)
RPIV := $(RPI)
DARCH := $(DIST_ARCH)
BOOT_DIR := boot
UBOOT_DIR := rpi_2

QEMU := qemu-arm-static

ifeq ($(findstring Raspbian,$(REPOS)),Raspbian)
	ifneq ($(findstring Foundation,$(REPOS)),Foundation)
		REPOS += Foundation
	endif
	REPOBASE := Raspbian
	DARCH := armhf
	ARCH := rpix
else ifeq ($(findstring Ubuntu,$(REPOS)),Ubuntu)
	REPOBASE := Ubuntu
	ifeq ($(findstring stretch,$(DIST)),stretch)
		DIST := yakkety
	endif
	BOOT_DIR := boot/firmware
	ARCH := raspi2
	DARCH := armhf
	RPIV := 2
else ifeq ($(findstring Debian,$(REPOS)),Debian)
	REPOBASE := Debian
	BOOT_DIR := boot/firmware
	ifeq ($(DARCH),arm64)
		ARCH := arm64
		UBOOT_DIR := rpi_3
	else ifeq ($(DARCH),armel)
		ARCH := armel
		UBOOT_DIR := rpi
	else
		ifeq ($(RPIV),3)
			UBOOT_DIR := rpi_3_32b
		endif
		DARCH := armhf
		ifneq ($(findstring armmp,$(ARCH)),armmp)
			ARCH := armmp
		endif
	endif
endif

ifeq ($(DARCH),arm64)
	QEMU := qemu-aarch64-static
	RPIV := 3
endif

ifeq ($(shell test $(BOOT_MB) -lt 38; echo $$?),0)
	BOOT_MB := 38
endif

ifeq ($(IMAGE_MB),-1)
	ROOT_MB := -1
else
	ROOT_MB := $(shell expr $(IMAGE_MB) - $(BOOT_MB))
endif

TIMESTAMP := $(shell date +'%Y-%m-%dT%H:%M:%S')
ROOT_DEV := /dev/mmcblk0p2
BASE_DIR := $(shell pwd)
ROOTFS_DIR := $(BASE_DIR)/rootfs
IMAGE_FILE := $(REPOBASE)-$(DIST)-$(ARCH)

ifeq ($(DIST),$(filter $(DIST), wheezy oldoldstable))
	FDIST := wheezy
else ifeq ($(DIST),$(filter $(DIST), jessie oldstable))
	FDIST := jessie
endif
