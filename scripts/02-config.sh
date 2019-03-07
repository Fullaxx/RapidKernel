#!/bin/bash

if [ -z "$1" ]; then
  >&2 echo "$0 <old config>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

ORIGIN=`pwd`
KOLDCONFIG="$1"

# Error Checking
if [ -f /usr/src/linux/.config ]; then bail "/usr/src/linux/.config exists!"; fi
if [ ! -r ${KOLDCONFIG} ]; then bail "${KOLDCONFIG} not found!"; fi

cp -v ${KOLDCONFIG} /usr/src/linux/.config || bail "cp ${KOLDCONFIG} /usr/src/linux/.config failed!"

cd /usr/src/linux && make menuconfig || bail "make menuconfig failed!"
