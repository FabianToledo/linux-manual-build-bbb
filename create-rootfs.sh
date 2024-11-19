#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

# Directories
DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${1:-$DEFAULT_OUTDIR})}
DIR="${PWD}"
# Architecture and compiler
ARCH=${ARCH:="arm"}
CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}
# busybox config
BUSYBOX_REPO=${BUSYBOX_REPO:=""}
BUSYBOX_VERSION=${BUSYBOX_VERSION:=""}
DEFCONFIG=am335x_evm_defconfig
