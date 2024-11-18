#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
export OUTDIR=$(realpath ${1:-$DEFAULT_OUTDIR})

UBOOT_REPO="https://github.com/u-boot/u-boot.git"
UBOOT_VERSION="v2024.10"
ARCH="arm"
CROSS_COMPILE="arm-cortex_a8-linux-gnueabihf-"
SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))
