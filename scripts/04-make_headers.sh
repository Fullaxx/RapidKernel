#!/bin/bash

# http://lwn.net/Articles/244375/

TEMPSTORAGE="/tmp/khtmp-$$"
HARCH=`uname -m`

if [ -z "$1" ]; then
  >&2 echo "$0 <output directory>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

KSAVEDIR="$1"

cd /usr/src/linux || bail "cd /usr/src/linux failed!"

# Error Checking
if [ ! -d ${KSAVEDIR} ]; then bail "${KSAVEDIR} not found!"; fi
if [ ! -r .config ]; then bail ".config not found!"; fi
if [ ! -f Module.symvers ]; then bail "Module.symvers not found!"; fi
if [ ! -f arch/x86/boot/bzImage ]; then bail "arch/x86/boot/bzImage not found!"; fi
if [ -d ${TEMPSTORAGE} ]; then bail "${TEMPSTORAGE} exists!"; fi

mkdir -p ${TEMPSTORAGE}/usr || bail "mkdir -p ${TEMPSTORAGE}/usr failed!"
make headers_install ARCH=${HARCH} INSTALL_HDR_PATH=${TEMPSTORAGE}/usr || bail "make headers_install failed!"
echo

find ${TEMPSTORAGE}/usr/ -name ..install.cmd -exec rm {} \;
find ${TEMPSTORAGE}/usr/ -name .install -exec rm {} \;

dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/kernel-headers.xzm && \
rm -rf ${TEMPSTORAGE} || bail "dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/kernel-headers.xzm"
