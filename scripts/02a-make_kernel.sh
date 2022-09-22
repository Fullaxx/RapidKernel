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

KSAVEDIR="$1"

cd /usr/src/linux || bail "cd /usr/src/linux failed!"

# Error Checking
if [ ! -d ${KSAVEDIR} ]; then bail "${KSAVEDIR} not found!"; fi
if [ ! -r .config ]; then bail ".config not found!"; fi

cp -v .config ${KSAVEDIR}/config || bail "cp -v .config ${KSAVEDIR}/config failed!"
make -j `nproc` || bail "Error during make"
echo

# Make modules before cleaning up the source tree.
# This does some magic in Module.symvers that fixes building the NVIDIA kernel modules.
make -j `nproc` modules || bail "Error during make modules"
echo

for FILE in arch/x86/boot/bzImage Module.symvers System.map scripts/module.lds; do
  cp -v ${FILE} ${KSAVEDIR}/ || bail "cp -v ${FILE} ${KSAVEDIR}/ failed!"
done
echo
