#!/bin/bash

if [ "$#" -ne "2" ]; then
  echo "$0: <OLDKVERS> <NEWKVERS>"
  exit 1
fi

RLPKGSDIR="/opt/RL/packages"
RKDIR=`dirname $0`
if [ "${RKDIR}" == "." ]; then
  RKDIR=`pwd`
fi

OLDKVERS="$1"
NEWKVERS="$2"

OLDKPKG="${RLPKGSDIR}/rapidkernels/64/${OLDKVERS}"
NEWKPKG="${RLPKGSDIR}/rapidkernels/64/${NEWKVERS}"

if [ ! -d ${OLDKPKG} ]; then
  echo "${OLDKPKG} does not exist!"
  exit 2
fi

if [ -e ${RKDIR}/patches ]; then
  PATCHES=`realpath ${RKDIR}/patches`
  DOCKERPATCHESARGUMENT="-v ${PATCHES}:/tmp/patches:ro"
fi

sudo docker run -it --rm --name kbuilder \
-e OLDKVERS="${OLDKVERS}" \
-e NEWKVERS="${NEWKVERS}" \
${DOCKERPATCHESARGUMENT} \
-v ${OLDKPKG}:/tmp/${OLDKVERS}:ro \
-v ${NEWKPKG}:/tmp/${NEWKVERS}:rw \
-v ${RKDIR}/autobuild.sh:/root/autobuild.sh:ro \
fullaxx/rapidbuild64 /root/autobuild.sh
