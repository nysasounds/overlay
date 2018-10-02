# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=3

inherit eutils linux-mod

MY_PV=${PV#*_p}

DVB_TBSAPI="linux-tbs-drivers"
DESCRIPTION="DVB driver for TBS Cards - this includes a whole new V4L tree"
HOMEPAGE="http://www.tbsdtv.com"
SRC_URI="http://www.tbsdtv.com/download/document/common/linux-tbs-drivers_${MY_PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nysasounds"
DEPEND="virtual/linux-sources \
app-arch/unzip \
"
RDEPEND=""

S=${WORKDIR}/${DVB_TBSAPI}

pkg_setup() {
	linux-mod_pkg_setup

	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	BUILD_TARGETS="all"
}

src_unpack() {
	unpack ${A}
	#tar xjf ${WORKDIR}/${DVB_TBSAPI}.tar.bz2
	elog "Fixing up package archive perms"
	find ${WORKDIR} -type d -exec chmod 755 {} \;
	find ${WORKDIR} -type f -exec chmod 644 {} \;
	find ${WORKDIR} -name "*.sh"  -exec chmod 755 {} \;
	find ${WORKDIR} -name "*.pl"  -exec chmod 755 {} \;

	epatch "${FILESDIR}/lsmod.patch"
	epatch "${FILESDIR}/depmod_make.patch"
}

src_configure() {
	cd ${WORKDIR}/${DVB_TBSAPI}
	# Prevent amd64 instead of x86_64 being used as system arch in linux tree #
	unset ARCH
	# Work around for seemingly odd kernel version detection #
	elog "Forcing v4l Makefile to detect correct kernel version via symlink"
	head -3 /usr/src/linux/Makefile > v4l/.version
	echo "KERNELRELEASE:=${KV_FULL}" >> v4l/.version
	# Run the appropriate set-up script depending on linux kernel arch and version #
	if use x86; then
		if [ "${KV_FULL#3}" != "$KV_FULL" ]; then
			elog "Setting up for linux x86 3.x"
			elog $(./v4l/tbs-x86_r3.sh)
		else
			elog "Setting up for linux x86 2.6.x"
			elog $(./v4l/tbs-x86.sh)
		fi
	elif use amd64; then
		elog "Setting up for linux x86_64 all"
		elog $(./v4l/tbs-x86_64.sh)
	fi
	if use nysasounds ; then
		einfo "Applying nysaosunds default config to v4v tree"
		epatch "${FILESDIR}/default-config.patch"
	fi
}

src_compile() {
	emake || die "emake failed"

	elog "post compile patches necessary..."
	epatch "${FILESDIR}/depmod_make-media.patch"
}

src_install() {
	emake install DESTDIR="${D}" DEST="/lib/modules/${KV_FULL}" || die "Install failed!"
}

pkg_postinst() {
	linux-mod_pkg_postinst
	ewarn "This installs a whole new v4l kernel tree"
	ewarn "For consistency, you need to reboot after installing these modules!"
}
