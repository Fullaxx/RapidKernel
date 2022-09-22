#!/bin/bash

# Make Cripple Sources

KSTMPSTOR="/tmp/kstmp-$$"
PERMTESTFILE="TEST-$$-TEST-$$-TEST.test"

if [ -z "$1" ]; then
  >&2 echo "$0 <output directory>"
  exit 1
fi

if [ -r ./vars.sh ]; then
  source ./vars.sh
else
  >&2 echo "./vars.sh does not exist!"
  exit 1
fi

KSAVEDIR="$1"

if [ ! -r ${KSAVEDIR}/config ]; then bail "${KSAVEDIR}/config not found!"; fi
if [ ! -r ${KSAVEDIR}/Module.symvers ]; then bail "${KSAVEDIR}/Module.symvers not found!"; fi
if [ ! -r ${KSAVEDIR}/System.map ]; then bail "${KSAVEDIR}/System.map not found!"; fi
if [ ! -r ${KSAVEDIR}/module.lds ]; then bail "${KSAVEDIR}/module.lds not found!"; fi
KFULLV=`cat ${KSAVEDIR}/config | grep '^# Linux/x86' | grep 'Kernel Configuration$' | awk '{print $3}'`

cd /usr/src/ || bail "cd /usr/src/ failed!"
if [ ! -r linux-${KFULLV}-src.tar ]; then bail "/usr/src/linux-${KFULLV}-src.tar not found!"; fi
touch ${PERMTESTFILE} && rm ${PERMTESTFILE} || exit 1

rm -rf linux-${KFULLV}
tar xf linux-${KFULLV}-src.tar || bail "tar xf linux-${KFULLV}-src.tar failed!"
cd linux-${KFULLV} || bail "cd linux-${KFULLV}"

if [ ! -d Documentation ]; then bail "Documentation not found!"; fi
mkdir -p ${KSTMPSTOR}/usr/src || bail "mkdir -p ${KSTMPSTOR}/usr/src failed!"
cp ${KSAVEDIR}/config ./.config || bail "cp ${KSAVEDIR}/config ./.config failed!"

make oldconfig
make prepare
make scripts
echo

# Comment these out if you want to keep them
rm -rf Documentation/??_??
rm -rf Documentation/translations

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

find . -type f -name .gitignore -exec rm {} \;
find . -type f -name .gitattributes -exec rm {} \;
find . -type f -name .mailmap -exec rm {} \;
find . -type f -name .cocciconfig -exec rm {} \;

# DO NOT CLEAN THE TOOLS DIR LIKE THIS
find block crypto drivers fs init ipc kernel lib mm net samples security sound virt \
-type f | grep -v Makefile | grep -v Kconfig | grep -v Kbuild | xargs rm

# Attempt to clean tools dir
rm -rf tools/{accounting,cgroup,firewire,gpio,hv,iio,kvm,laptop,leds,net,nfsd,pci,pcmcia,perf,power,spi,testing,thermal,time,usb,virtio,vm}

find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir
find . -type d -empty | xargs -r rmdir

find arch -name '*.c' -exec rm {} \;
find . -type f -name '*.tst' -exec rm {} \;
find . -type f -name '*.cmd' -exec rm {} \;
find . -type f -name '*.S' -exec rm {} \;
find . -type l -name '*.S' -exec rm {} \;

# compressing the docs into a tar.xz appears to give better module size than leaving it alone
tar Jcf Documentation.tar.xz Documentation && rm -r Documentation

cp ${KSAVEDIR}/System.map ./System.map || bail "cp ${KSAVEDIR}/System.map ./System.map failed!"
cp ${KSAVEDIR}/Module.symvers ./Module.symvers || bail "cp ${KSAVEDIR}/Module.symvers ./Module.symvers failed!"
cp ${KSAVEDIR}/module.lds ./scripts/ || bail "cp ${KSAVEDIR}/module.lds ./scripts/ failed!"

echo -n "Cripple Sources Size: "
du -sh . | awk '{print $1}'
echo

cd /usr/src/ || bail "cd /usr/src/ failed!"
mv linux-${KFULLV} ${KSTMPSTOR}/usr/src/
cp README.IMPORTANT ${KSTMPSTOR}/usr/src/
ln -s linux-${KFULLV} ${KSTMPSTOR}/usr/src/linux

dir2xzm ${KSTMPSTOR} ${KSAVEDIR}/kernel-crippledsrc.xzm && \
rm -rf ${KSTMPSTOR} || bail "dir2xzm ${KSTMPSTOR} ${KSAVEDIR}/kernel-crippledsrc.xzm failed!"

rm -f /usr/src/linux-${KFULLV}-src.tar
if [ -L /usr/src/linux ]; then rm /usr/src/linux; fi
