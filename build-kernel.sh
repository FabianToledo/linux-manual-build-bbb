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
IMAGE_TYPE=zImage

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
        cp -v "${OUTDIR}/linux/.config" "${DIR}/.kernelconfig"
    else
        cp -v "${DIR}/.kernelconfig" "${OUTDIR}/linux/.config"
    fi
    # Build kernel
	make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE} ${IMAGE_TYPE}
    # Build modules
    make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE} modules
    # Build device tree blobs
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

    mkdir -p "${OUTDIR}/linux-output"
    # Copy kernel image
    cp -v "${OUTDIR}/linux/arch/${ARCH}/boot/${IMAGE_TYPE}" "${OUTDIR}/linux-output"
    # Find and copy dtb for am335x-boneblack
    cp -v "$(find ${OUTDIR}/linux/arch/${ARCH}/boot -name 'am335x-boneblack.dtb')" "${OUTDIR}/linux-output"
fi

if [ -d "${OUTDIR}/rootfs" ]; then
    cd "${OUTDIR}/linux"
    # Install modules
    make ARCH=${ARCH} -j2 CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH="${OUTDIR}/rootfs" modules_install
    cp -v "${OUTDIR}/linux-output"/* "${OUTDIR}/rootfs/boot"
fi