#!/bin/sh

# Exits if any command fails
set -e
# Expanding a non-set variable will fail
set -u

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${1:-$DEFAULT_OUTDIR})}
DIR="${PWD}"
UBOOT_REPO=${UBOOT_REPO:="https://github.com/u-boot/u-boot.git"}
UBOOT_VERSION=${UBOOT_VERSION:="v2024.10"}
DEFCONFIG=am335x_evm_defconfig
ARCH=${ARCH:="arm"}
CROSS_COMPILE=${CROSS_COMPILE:="arm-cortex_a8-linux-gnueabihf-"}
# SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))

mkdir -p "${OUTDIR}"

if [ ! -d "${OUTDIR}/u-boot" ]; then
    cd "${OUTDIR}"
    echo Cloning u-boot git repo
    git clone ${UBOOT_REPO}
fi

if [ ! -d "${OUTDIR}/u-boot-output" ]; then
    cd "${OUTDIR}/u-boot"
    git checkout ${UBOOT_VERSION}
    if [ ! -f "${DIR}/.ubootconfig" ]; then
        make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${DEFCONFIG}
        make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig
        cp -v "${OUTDIR}/u-boot/.config" "${DIR}/.ubootconfig"
    else
        cp -v "${DIR}/.ubootconfig" "${OUTDIR}/u-boot/.config"
    fi

	make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE}

    mkdir -p "${OUTDIR}/u-boot-output"
    cp -v "${OUTDIR}/u-boot/MLO" "${OUTDIR}/u-boot-output"
    # This compilation includes the dtb in the u-boot-dtb.img file
    cp -v "${OUTDIR}/u-boot/u-boot-dtb.img" "${OUTDIR}/u-boot-output"
fi

