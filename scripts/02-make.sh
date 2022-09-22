#!/bin/bash

if [ -z "$1" ]; then
  echo "$0 <output directory>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

HARCH=`uname -m`
KHTMPSTOR="/tmp/khtmp-$$"
KMTMPSTOR="/tmp/kmtmp-$$"
KSAVEDIR="$1"

SCRLOC=`dirname $0`
if [ "${SCRLOC}" == "." ]; then
  SCRLOC=`pwd`
fi

cd /usr/src/linux || bail "cd /usr/src/linux failed!"

# Error Checking
if [ ! -d ${KSAVEDIR} ]; then bail "${KSAVEDIR} not found!"; fi
if [ ! -r .config ]; then bail ".config not found!"; fi

cp -v .config ${KSAVEDIR}/config || bail "cp -v .config ${KSAVEDIR}/config failed!"
make -j `nproc` || bail "Error during make"

# Make modules before cleaning up the source tree.
# This does some magic in Module.symvers that fixes building the NVIDIA kernel modules.
make -j `nproc` modules || bail "Error during make modules"
echo

cp -v arch/x86/boot/bzImage Module.symvers System.map ${KSAVEDIR}/ || bail "cp -v arch/x86/boot/bzImage Module.symvers System.map ${KSAVEDIR}/ failed!"
echo

# Make Headers
# http://lwn.net/Articles/244375/

# Error Checking
if [ ! -f Module.symvers ]; then bail "Module.symvers not found!"; fi
if [ ! -f arch/x86/boot/bzImage ]; then bail "arch/x86/boot/bzImage not found!"; fi
if [ -d ${KHTMPSTOR} ]; then bail "${KHTMPSTOR} exists!"; fi

mkdir -p ${KHTMPSTOR}/usr || bail "mkdir -p ${KHTMPSTOR}/usr failed!"
make headers_install ARCH=${HARCH} INSTALL_HDR_PATH=${KHTMPSTOR}/usr || bail "make headers_install failed!"
echo

find ${KHTMPSTOR}/usr/ -name ..install.cmd -exec rm {} \;
find ${KHTMPSTOR}/usr/ -name .install -exec rm {} \;

dir2xzm ${KHTMPSTOR} ${KSAVEDIR}/kernel-headers.xzm && \
rm -rf ${KHTMPSTOR} || bail "dir2xzm ${KHTMPSTOR} ${KSAVEDIR}/kernel-headers.xzm"

cd ${SCRLOC}
./02b-make_modules.sh ${KSAVEDIR}

cd ${SCRLOC}
./02c-make_cripple_sources.sh ${KSAVEDIR}
