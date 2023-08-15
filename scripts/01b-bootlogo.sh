LOGODIR="/opt/RL/RapidKernel/logo"
LOGO="${LOGODIR}/logo_borg_clut224.ppm"

echo "Installing ${LOGO} ..."
cat ${LOGO} >drivers/video/logo/logo_linux_clut224.ppm
