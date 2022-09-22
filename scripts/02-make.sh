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

SCRLOC=`dirname $0`
if [ "${SCRLOC}" == "." ]; then
  SCRLOC=`pwd`
fi

cd ${SCRLOC}
./02a-make_kernel.sh ${KSAVEDIR}

cd ${SCRLOC}
./02b-make_headers.sh ${KSAVEDIR}

cd ${SCRLOC}
./02c-make_modules.sh ${KSAVEDIR}

cd ${SCRLOC}
./02d-make_cripple_sources.sh ${KSAVEDIR}
