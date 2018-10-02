# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=3

inherit eutils linux-mod


MY_PV=${PV#*_p}

DVB_TBSAPI="linux-tbs-drivers"
DESCRIPTION="DVB driver for TBS Cards - this includes a whole new V4L tree"
HOMEPAGE="http://www.tbsdtv.com"
SRC_URI="http://www.tbsdtv.com/download/document/common/tbs-linux-drivers_v${MY_PV}.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
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
	tar xjf ${WORKDIR}/${DVB_TBSAPI}.tar.bz2
	elog "Fixing up package archive perms"
	find ${WORKDIR} -type d -exec chmod -c 755 {} \;
	find ${WORKDIR} -type f -exec chmod -c 644 {} \;
	find ${WORKDIR} -name "*.sh"  -exec chmod -c 755 {} \;
	find ${WORKDIR} -name "*.pl"  -exec chmod -c 755 {} \;

	epatch "${FILESDIR}/lsmod.patch"
	epatch "${FILESDIR}/depmod_make.patch"
}

src_configure() {
	cd ${WORKDIR}/${DVB_TBSAPI}
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
	ewarn "For consistency, you need to reboot after install these modules!"
}
