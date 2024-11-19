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
# kernel config
KERNEL_REPO=${KERNEL_REPO:="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"}
KERNEL_VERSION=${KERNEL_VERSION:="v6.6.62"}
DEFCONFIG=multi_v7_defconfig
SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))

mkdir -p "${OUTDIR}"

if [ ! -d "${OUTDIR}/linux" ]; then
    cd "${OUTDIR}"
    echo Cloning u-boot git repo
    git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

if [ ! -d "${OUTDIR}/linux-output" ]; then
    cd "${OUTDIR}/linux"
    git checkout ${KERNEL_VERSION}
    # Clean
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    # Config
    if [ ! -f "${DIR}/.kernelconfig" ]; then
        make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${DEFCONFIG}
        make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig
        cp -v "${OUTDIR}/u-boot/.config" "${DIR}/.kernelconfig"
    else
        cp -v "${DIR}/.kernelconfig" "${OUTDIR}/u-boot/.config"
    fi
    # Build kernel
	make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE} zImage
    # Build modules
    make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE} modules
    # Build device tree blobs
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

    mkdir -p "${OUTDIR}/linux-output"
    cp -v "${OUTDIR}/linux/arch/${ARCH}/boot/zImage" "${OUTDIR}/linux-output"
    cp -v "${OUTDIR}/linux/arch/${ARCH}/boot/dts/ti/omap/am335x-boneblack.dtb" "${OUTDIR}/linux-output"
fi
