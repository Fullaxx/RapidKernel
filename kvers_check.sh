#!/bin/bash

KMAJV="5.15"
NEWKVERS=`curl -s https://www.kernel.org/ | grep "<td><strong>${KMAJV}.*</strong></td>" | tr '[<>]' ' ' | awk '{print $3}'`

if [ -d /opt/RL/packages/rapidkernels/64/${NEWKVERS} ]; then
  echo "${NEWKVERS} already exists!"
  exit 0
fi

for KPKGPATH in `ls -1d /opt/RL/packages/rapidkernels/64/${KMAJV}.*`; do LASTKVERS=`basename ${KPKGPATH}`; done
echo "LASTKVERS: ${LASTKVERS}"
echo "NEWKVERS: ${NEWKVERS}"
echo -n "Would you like to build ${NEWKVERS}? "
read ANS
if [ ${ANS} == "y" ] || [ ${ANS} == "Y" ]; then
  ./launch_kbuilder.sh ${LASTKVERS} ${NEWKVERS}
fi
