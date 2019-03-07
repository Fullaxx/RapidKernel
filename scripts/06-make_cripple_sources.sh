#!/bin/bash

TEMPSTORAGE="/tmp/kstmp-$$"
PERMTESTFILE="TEST-$$-TEST-$$-TEST.test"

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

cd /usr/src/ || bail "cd /usr/src/ failed!"

# Error Checking
if [ ! -r linux-${KFULLV}-src.tar ]; then bail "/usr/src/linux-${KFULLV}-src.tar not found!"; fi
touch ${PERMTESTFILE} && rm ${PERMTESTFILE} || exit 1

rm -rf linux-${KFULLV}
tar xf linux-${KFULLV}-src.tar || bail "tar xf linux-${KFULLV}-src.tar failed!"
cd linux-${KFULLV} || bail "cd linux-${KFULLV}"

# Error Checking
if [ ! -d Documentation ]; then bail "Documentation not found!"; fi
if [ ! -r ${KSAVEDIR}/config ]; then bail "${KSAVEDIR}/config not found!"; fi
if [ ! -r ${KSAVEDIR}/Module.symvers ]; then bail "${KSAVEDIR}/Module.symvers not found!"; fi

mkdir -p ${TEMPSTORAGE}/usr/src || bail "mkdir -p ${TEMPSTORAGE}/usr/src failed!"

cp ${KSAVEDIR}/config ./.config || bail "cp ${KSAVEDIR}/config ./.config failed!"

make oldconfig
make prepare
make scripts
echo

# Comment these out if you want to keep them
rm -rf Documentation/ja_JP
rm -rf Documentation/ko_KR
rm -rf Documentation/zh_CN

# Remove a lot of stuff (not Documentation)
rm -rf .config.old
rm -rf .get_maintainer.ignore
rm -rf .missing-syscalls.d
rm -rf firmware
rm -rf COPYING
rm -rf CREDITS
rm -rf MAINTAINERS
rm -rf REPORTING-BUGS

ls -1d arch/* | grep -v x86 | grep -v Kconfig | xargs rm -rf

find block crypto drivers fs init ipc kernel lib mm net samples security sound tools virt \
-type f | grep -v Makefile | grep -v Kconfig | grep -v Kbuild | xargs rm

find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type f -name .gitignore -exec rm {} \;
find . -type f -name .mailmap -exec rm {} \;

find arch -name *.c -exec rm {} \;
find . -type f -name *.tst -exec rm {} \;
find . -type f -name '*.cmd' -exec rm {} \;
find . -type f -name *.S -exec rm {} \;
find . -type l -name *.S -exec rm {} \;

find tools -type l -name *.c -exec rm {} \;
find tools -type l -name *.h -exec rm {} \;

# compressing the docs into a tar.xz appears to give better module size that leaving it alone
tar Jcf Documentation.tar.xz Documentation && rm -r Documentation

cp ${KSAVEDIR}/Module.symvers ./Module.symvers || bail "cp ${KSAVEDIR}/Module.symvers ./Module.symvers failed!"

echo -n "Cripple Sources Size: "
du -sh . | awk '{print $1}'
echo

cd /usr/src/ || bail "cd /usr/src/ failed!"
mv linux-${KFULLV} ${TEMPSTORAGE}/usr/src/
cp README.IMPORTANT ${TEMPSTORAGE}/usr/src/
ln -s linux-${KFULLV} ${TEMPSTORAGE}/usr/src/linux

dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/kernel-crippledsrc.xzm && \
rm -rf ${TEMPSTORAGE} || bail "dir2xzm ${TEMPSTORAGE} ${KSAVEDIR}/kernel-crippledsrc.xzm failed!"

rm -f /usr/src/linux-${KFULLV}-src.tar
if [ -L /usr/src/linux ]; then rm /usr/src/linux; fi
