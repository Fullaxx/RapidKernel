AUFSGITDIR="aufs-standalone.git"

case "${KMAJV}" in
  3.14)
    AUFSREPO="git://git.code.sf.net/p/aufs/aufs3-standalone"
    AUFSBRANCH="aufs3.14.21+" ;;
  3.16)
    AUFSREPO="git://git.code.sf.net/p/aufs/aufs3-standalone"
    AUFSBRANCH="aufs3.16" ;;
  3.18)
    AUFSREPO="git://git.code.sf.net/p/aufs/aufs3-standalone"
    AUFSBRANCH="aufs3.18.1+" ;;
   4.1)
    AUFSREPO="https://github.com/sfjro/aufs4-standalone.git"
    AUFSBRANCH="aufs4.1.13+" ;;
   4.4)
    AUFSREPO="https://github.com/sfjro/aufs4-standalone.git"
    AUFSBRANCH="aufs4.4" ;;
   4.9)
    AUFSREPO="https://github.com/sfjro/aufs4-standalone.git"
    AUFSBRANCH="aufs4.9.94+" ;;
  4.14)
    AUFSREPO="https://github.com/sfjro/aufs4-standalone.git"
    AUFSBRANCH="aufs4.14.56+" ;;
  4.19)
    AUFSREPO="https://github.com/sfjro/aufs4-standalone.git"
    AUFSBRANCH="aufs4.19.63+" ;;
   5.4)
    AUFSREPO="https://github.com/sfjro/aufs5-standalone.git"
    AUFSBRANCH="aufs5.4.3" ;;
  5.10)
    AUFSREPO="https://github.com/sfjro/aufs5-standalone.git"
    AUFSBRANCH="aufs5.10.140" ;;
  *) bail "${KMAJV}: Unsupported AUFS Version"; exit 1 ;;
esac

git clone ${AUFSREPO} ${TEMPSTORAGE}/${AUFSGITDIR} -b ${AUFSBRANCH} || bail "git clone ${AUFSREPO} ${TEMPSTORAGE}/${AUFSGITDIR} -b ${AUFSBRANCH} failed!"

echo "Patching AUFS"
patch -p1 < ${TEMPSTORAGE}/${AUFSGITDIR}/aufs?-kbuild.patch || bail "patching aufs?-kbuild.patch"
patch -p1 < ${TEMPSTORAGE}/${AUFSGITDIR}/aufs?-base.patch || bail "patching aufs?-base.patch"
patch -p1 < ${TEMPSTORAGE}/${AUFSGITDIR}/aufs?-mmap.patch || bail "patching aufs?-mmap.patch"
cp -r ${TEMPSTORAGE}/${AUFSGITDIR}/{Documentation,fs} ./ || bail "patching aufs docs"

case "${KMAJV}" in
  3.1?) cp ${TEMPSTORAGE}/${AUFSGITDIR}/include/uapi/linux/aufs_type.h include/uapi/linux/ || bail "patching aufs header" ;;
   4.*) cp ${TEMPSTORAGE}/${AUFSGITDIR}/include/uapi/linux/aufs_type.h include/uapi/linux/ || bail "patching aufs header" ;;
   5.*) cp ${TEMPSTORAGE}/${AUFSGITDIR}/include/uapi/linux/aufs_type.h include/uapi/linux/ || bail "patching aufs header" ;;
     *) cp ${TEMPSTORAGE}/${AUFSGITDIR}/include/linux/aufs_type.h include/linux/ || bail "patching aufs header" ;;
esac

echo
