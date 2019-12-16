#!/bin/bash

KMTMPSTOR="/tmp/kmtmp-$$"

if [ -z "$1" -o -z "$2" ]; then
  >&2 echo "$0 <kernel version> <output directory>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

KFULLV="$1"
KSAVEDIR="$2"

cd /usr/src/linux || bail "cd /usr/src/linux failed!"

# Error Checking
if [ ! -d ${KSAVEDIR} ]; then bail "${KSAVEDIR} not found!"; fi
if [ ! -r .config ]; then bail ".config not found!"; fi
if [ -d ${KMTMPSTOR} ]; then bail "${KMTMPSTOR} exists!"; fi

mkdir -p ${KMTMPSTOR}/lib/modules || bail "mkdir -p ${KMTMPSTOR}/lib/modules failed!"
make modules_install || bail "make modules_install"
echo

mv /lib/modules/${KFULLV}/ ${KMTMPSTOR}/lib/modules/ || bail "mv /lib/modules/${KFULLV}/ ${KMTMPSTOR}/lib/modules/ failed!"

dir2xzm ${KMTMPSTOR} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm && \
rm -rf ${KMTMPSTOR} || bail "dir2xzm ${KMTMPSTOR} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm"
