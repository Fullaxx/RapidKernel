
bail()
{
  >&2 echo "$1"
  exit 1
}

kmajvchk()
{

case "${KMAJV}" in
  3.14) echo "Kernel 3.14 Supported" ;;
  3.16) echo "Kernel 3.16 Supported" ;;
  3.18) echo "Kernel 3.18 Supported" ;;
   4.1) echo "Kernel  4.1 Supported" ;;
   4.4) echo "Kernel  4.4 Supported" ;;
   4.9) echo "Kernel  4.9 Supported" ;;
  4.14) echo "Kernel 4.14 Supported" ;;
     *) bail "${KMAJV}: Unsupported Kernel Version"; exit 1 ;;
esac

case "${KMAJV}" in
  3.*) KMAJDIR="v3.x" ;;
  4.*) KMAJDIR="v4.x" ;;
    *) bail "${KMAJV}: Unsupported Kernel Version"; exit 1 ;;
esac

KDLURL="https://cdn.kernel.org/pub/linux/kernel/${KMAJDIR}/linux-${KFULLV}.tar.xz"

echo

}
