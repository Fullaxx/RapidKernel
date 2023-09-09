#!/bin/bash

# Make Modules

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

KMTMPSTOR="/tmp/kmtmp-$$"
KSAVEDIR="$1"

cd /usr/src/linux || bail "cd /usr/src/linux failed!"

# Error Checking
if [ ! -d ${KSAVEDIR} ]; then bail "${KSAVEDIR} not found!"; fi
if [ ! -r .config ]; then bail ".config not found!"; fi

# Error Checking
if [ -d ${KMTMPSTOR} ]; then bail "${KMTMPSTOR} exists!"; fi
KFULLV=`cat .config | grep '^# Linux/x86' | grep 'Kernel Configuration$' | awk '{print $3}'`

mkdir -p ${KMTMPSTOR}/lib/modules || bail "mkdir -p ${KMTMPSTOR}/lib/modules failed!"
make modules_install || bail "make modules_install"
echo

if [ ! -d /lib/modules/${KFULLV} ]; then bail "/lib/modules/${KFULLV} does not exist"; fi
mv /lib/modules/${KFULLV}/ ${KMTMPSTOR}/lib/modules/ || bail "mv /lib/modules/${KFULLV}/ ${KMTMPSTOR}/lib/modules/ failed!"

dir2xzm ${KMTMPSTOR} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm && \
rm -rf ${KMTMPSTOR} || bail "dir2xzm ${KMTMPSTOR} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm"
