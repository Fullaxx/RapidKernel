#!/bin/bash

set -e

update-ca-certificates
mkdir /opt/RL/
cd /opt/RL/

git clone https://github.com/Fullaxx/RapidKernel

if [ -d /tmp/patches ]; then
  cp -av /tmp/patches RapidKernel/
fi

cd RapidKernel/scripts

if [ -r ../patches/01w-wireless_patch.sh ]; then
  ln -s ../patches/01w-wireless_patch.sh
fi

./01-prepare.sh ${NEWKVERS} /tmp/${OLDKVERS}/config
./02-build.sh /tmp/${NEWKVERS}/
