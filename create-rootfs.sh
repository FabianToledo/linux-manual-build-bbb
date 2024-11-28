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
DEFCONFIG=defconfig

SYSROOT=$(realpath $(${CROSS_COMPILE}gcc -print-sysroot))

echo "Creating the staging directory for the root filesystem"
cd "${OUTDIR}"
if [ ! -d "${OUTDIR}/rootfs" ]
then
    # Create necessary base directories
    echo "Creating necessary base directories"
    mkdir -p "${OUTDIR}/rootfs"
    cd "${OUTDIR}/rootfs"
    mkdir -p bin boot dev etc home lib lib64 proc sbin tmp usr/bin usr/lib usr/sbin var/log
fi

cd "${OUTDIR}"
if [ ! -d "${OUTDIR}/busybox" ]
then
    git clone git://busybox.net/busybox.git
fi

if [ ! -f ${OUTDIR}/rootfs/bin/busybox ]; then
    cd "${OUTDIR}"/busybox
    git checkout ${BUSYBOX_VERSION}
    # Configure busybox
    echo "Configuring busybox"
    make distclean

    # Config
    if [ ! -f "${DIR}/.busyboxconfig" ]; then
        make ${DEFCONFIG}
        make menuconfig
        cp -v "${OUTDIR}/busybox/.config" "${DIR}/.busyboxconfig"
    else
        cp -v "${DIR}/.busyboxconfig" "${OUTDIR}/busybox/.config"
    fi

    # Make and install busybox
    echo "Compiling busybox"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
    echo "Installing busybox in ${OUTDIR}/rootfs"
    make CONFIG_PREFIX=${OUTDIR}/rootfs  ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

    echo "Library dependencies"
    INTERPRETER=$(${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter" | sed -n -e 's/^.*interpreter: //p' | sed -n -e 's/].*$//p')
    SHRD_LIBS=$(${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library" | sed -n -e 's/^.*library: \[//p' | sed -n -e 's/].*$//p')
    echo Program interpreter: $INTERPRETER
    echo Shared libraries: $SHRD_LIBS

    # Add library dependencies to rootfs
    echo "Copying Library dependencies to rootfs"
    cp -v "${SYSROOT}${INTERPRETER}" "${OUTDIR}/rootfs/lib"
    for FILE in ${SHRD_LIBS}; do
        cp -v "${SYSROOT}/lib/${FILE}" "${OUTDIR}/rootfs/lib"
    done
fi

if [ -d "${OUTDIR}/rootfs" ]; then
    chmod 4755 "${OUTDIR}"/rootfs/bin/busybox
    cp -v "${DIR}"/initrootfs/passwd "${OUTDIR}"/rootfs/etc
    cp -v "${DIR}"/initrootfs/group "${OUTDIR}"/rootfs/etc
    cp -v "${DIR}"/initrootfs/inittab "${OUTDIR}"/rootfs/etc
    mkdir -p "${OUTDIR}"/rootfs/etc/init.d
    cp -v "${DIR}"/initrootfs/rcS "${OUTDIR}"/rootfs/etc/init.d
fi


