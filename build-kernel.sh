#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${1:-$DEFAULT_OUTDIR})}

KERNEL_REPO=${KERNEL_REPO:="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"}
KERNEL_VERSION=${KERNEL_VERSION:="6.6.62"}
ARCH=${ARCH:="arm"}
CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}
SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))
