#!/bin/bash

DEFAULT_DISK="/media/${USER}/rootfs"
DISK=${1:-$DEFAULT_DISK}
if [ ! -d "${DISK}" ]; then
	echo $DISK does not exist
	exit 1
fi

DEFAULT_OUTDIR="${HOME}/Desktop/aesd/manual-build-bbb"
OUTDIR=${OUTDIR:=$(realpath ${2:-$DEFAULT_OUTDIR})}
ROOTFS_OUTDIR="${OUTDIR}/rootfs"

echo "Using [${DISK}]"
if [ -d "$ROOTFS_OUTDIR" ] ; then
	sudo cp -v -r "$ROOTFS_OUTDIR"/* "$DISK"
else
	echo "rootfs does not exist. First create a rootfs with create-rootfs.sh"
fi

