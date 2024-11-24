#!/bin/bash

DEFAULT_DISK="/media/${USER}/boot"
DISK=${1:-$DEFAULT_DISK}
if [ ! -d "${DISK}" ]; then
	echo $DISK does not exist
	exit 1
fi

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${2:-$DEFAULT_OUTDIR})}
UBOOT_OUTDIR="${OUTDIR}/u-boot-output"

SPL=MLO
TPL=u-boot.img

echo "Using [${DISK}]"
if [ -f ${UBOOT_OUTDIR}/${SPL} ] && [ -f ${UBOOT_OUTDIR}/${TPL} ] ; then
	cp -v "${UBOOT_OUTDIR}/${SPL}" "${DISK}"
	cp -v "${UBOOT_OUTDIR}/${TPL}" "${DISK}"
else
	echo "Build u-boot with build-uboot.sh first"
fi

