#!/bin/bash

DISK=${1:?"You must supply a device. e.g. /dev/sdb"}

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${2:-$DEFAULT_OUTDIR})}
UBOOT_OUTDIR="${OUTDIR}/u-boot-output"

SPL=MLO
TPL=u-boot.img

echo "Using [${DISK}]"
if [ -f ${UBOOT_OUTDIR}/${SPL} ] && [ -f ${UBOOT_OUTDIR}/${TPL} ] ; then
	if [ -b ${DISK} ] ; then
		echo "dd if=${UBOOT_OUTDIR}/${SPL} of=${DISK} count=2 seek=1 bs=128k"
		sudo dd if=${UBOOT_OUTDIR}/${SPL} of=${DISK} count=2 seek=1 bs=128k
		echo "dd if=${OUTDIR}/${TPL} of=${DISK} count=4 seek=1 bs=384k"
		sudo dd if=${UBOOT_OUTDIR}/${TPL} of=${DISK} count=4 seek=1 bs=384k
	fi
else
	echo "Build u-boot with build-uboot.sh first"
fi

