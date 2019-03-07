#!/bin/bash

TEMPSTORAGE="/tmp/kmtmp-$$"

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
if [ -d ${TEMPSTORAGE} ]; then bail "${TEMPSTORAGE} exists!"; fi

mkdir -p ${TEMPSTORAGE}/lib/modules || bail "mkdir -p ${TEMPSTORAGE}/lib/modules failed!"
make modules_install || bail "make modules_install"
echo

mv /lib/modules/${KFULLV}/ ${TEMPSTORAGE}/lib/modules/ || bail "mv /lib/modules/${KFULLV}/ ${TEMPSTORAGE}/lib/modules/ failed!"

dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm && \
rm -rf ${TEMPSTORAGE} || bail "dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/000-kmods-${KFULLV}.xzm"
