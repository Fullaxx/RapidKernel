#!/bin/bash

TEMPSTORAGE="/tmp/ktmp-$$"
PERMTESTFILE="TEST-$$-TEST-$$-TEST.test"

if [ "$#" -ne "2" ]; then
  >&2 echo "$0 <kernel version> <old config>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

ORIGIN=`pwd`
KFULLV="$1"
KOLDCONFIG="$2"
KMAJV=`echo ${KFULLV} | cut -d. -f1-2`

# Run a quick check to make sure we aren't attempting anything outlandish :-)
kmajvchk

cd /usr/src/ || bail "cd /usr/src/ failed!"

# Error Checking
touch ${PERMTESTFILE} && rm ${PERMTESTFILE} || exit 1
if [ -d ${TEMPSTORAGE} ]; then bail "${TEMPSTORAGE} exists!"; fi
mkdir ${TEMPSTORAGE} || bail "mkdir ${TEMPSTORAGE} failed!"
if [ ! -r ${KOLDCONFIG} ]; then bail "${KOLDCONFIG} not found!"; fi

# Use a local file or download what we need
if [ -n "${LOCALKERNELSTORAGEDIR}" ]; then
  cp ${LOCALKERNELSTORAGEDIR}/linux-${KFULLV}.tar.xz ${TEMPSTORAGE}/ || bail "cp ${LOCALKERNELSTORAGEDIR}/linux-${KFULLV}.tar.xz ${TEMPSTORAGE}/"
  echo "Using ${LOCALKERNELSTORAGEDIR}/linux-${KFULLV}.tar.xz"
else
# wget ${KDLURL} -O ${TEMPSTORAGE}/linux-${KFULLV}.tar.xz || bail "Download failed!"
  curl ${KDLURL} -o ${TEMPSTORAGE}/linux-${KFULLV}.tar.xz || bail "Download failed!"
fi

echo
echo "Extracting ${TEMPSTORAGE}/linux-${KFULLV}.tar.xz ..."
tar xf ${TEMPSTORAGE}/linux-${KFULLV}.tar.xz || bail "tar xf ${TEMPSTORAGE}/linux-${KFULLV}.tar.xz failed!"
rm -f linux || bail "rm -f linux failed!"
ln -s linux-${KFULLV} linux || bail "ln -s linux-${KFULLV} linux failed!"
cd linux || bail "cd linux failed!"

# Run any patches we need, including AUFS
for PSCRIPT in ${ORIGIN}/01?-*.sh; do . ${PSCRIPT}; done

cd /usr/src/ || bail "cd /usr/src/ failed!"

# Save this for later steps
tar cf linux-${KFULLV}-src.tar linux-${KFULLV} || bail "tar cf linux-${KFULLV}-src.tar linux-${KFULLV}"

# Clean Up
rm -rf ${TEMPSTORAGE}

cd /usr/src/linux || bail "cd /usr/src/linux failed!"
if [ -f .config ]; then bail "/usr/src/linux/.config exists!"; fi
cp -v ${KOLDCONFIG} /usr/src/linux/.config || bail "cp ${KOLDCONFIG} /usr/src/linux/.config failed!"
KOLDV=`cat /usr/src/linux/.config | grep '^# Linux/x86' | grep 'Kernel Configuration$' | awk '{print $3}'`
sed -e "s@Linux/x86 ${KOLDV} Kernel Configuration@Linux/x86 ${KFULLV} Kernel Configuration@" -i .config
make menuconfig || bail "make menuconfig failed!"
