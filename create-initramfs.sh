#!/bin/sh

# Directories
DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${1:-$DEFAULT_OUTDIR})}

# Creates the rootfs in cpio format to use as initramfs
if [ ! -d "${OUTDIR}/initramfs" ]; then
    mkdir -p "${OUTDIR}/initramfs"
    cd "${OUTDIR}/rootfs"
    find . | cpio -H newc -ov --owner root:root > "${OUTDIR}"/initramfs/initramfs.cpio
    cd "${OUTDIR}/initramfs"
    # gz compress
    cat initramfs.cpio | gzip > initramfs.cpio.gz
    # create header for u-boot
    mkimage -A arm -O linux -T ramdisk -a 0x80AA0000 -C none -n rootfs -d initramfs.cpio.gz uInitramfs
fi