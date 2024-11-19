#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
export OUTDIR=$(realpath ${1:-$DEFAULT_OUTDIR})

# Architecture and compiler
export ARCH=${ARCH:="arm"}
export CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}

./build-uboot.sh
./create-rootfs.sh
./build-kernel.sh

