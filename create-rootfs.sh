#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${1:-$DEFAULT_OUTDIR})}

BUSYBOX_REPO=${BUSYBOX_REPO:=""}
BUSYBOX_VERSION=${BUSYBOX_VERSION:=""}
ARCH=${ARCH:="arm"}
CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}
SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))
