#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
export OUTDIR=$(realpath ${1:-$DEFAULT_OUTDIR})
DIR="${PWD}"
# Architecture and compiler
ARCH=${ARCH:="arm"}
CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}
# u-boot config
UBOOT_REPO=${UBOOT_REPO:="https://github.com/u-boot/u-boot.git"}
UBOOT_VERSION=${UBOOT_VERSION:="v2024.10"}
DEFCONFIG=am335x_evm_defconfig


