# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 linux-mod

DESCRIPTION="TBS DVB Card drivers [ Open Source ] - this includes a whole new V4L tree"
HOMEPAGE="https://github.com/tbsdtv/linux_media"

EGIT_REPO_URI="https://github.com/tbsdtv/linux_media.git"
EGIT_BRANCH="latest"
EGIT_CLONE_TYPE="shallow"

MEDIA_BUILD_EGIT_REPO_URI="https://github.com/tbsdtv/media_build.git"
MEDIA_BUILD_EGIT_BRANCH="master"
MEDIA_BUILD_EGIT_CLONE_TYPE="shallow"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="\
virtual/linux-sources \
dev-vcs/git \
net-misc/wget \
dev-util/patchutils \
dev-perl/Proc-ProcessTable \
"
RDEPEND="\
virtual/linux-sources \
media-tv/tbs-dvb-firmware \
!!media-tv/tbs-drivers \
"
BDEPEND=""


src_prepare() {

	# Build helper repo - media_build #
	elog "Fetching build system..."
	EGIT_REPO_URI="${MEDIA_BUILD_EGIT_REPO_URI}"
	EGIT_BRANCH="${MEDIA_BUILD_EGIT_BRANCH}"
	EGIT_CLONE_TYPE="${MEDIA_BUILD_EGIT_CLONE_TYPE}"

	EGIT_CHECKOUT_DIR="${WORKDIR}/media_build"

	git-r3_fetch
	git-r3_checkout

	eapply_user

}


src_configure() {

	# Prevent amd64 instead of x86_64 being used as system arch in linux tree #
	unset ARCH

	cd ${WORKDIR}/media_build

	# lsmod path and remove unwanted depmod #
	eapply "${FILESDIR}/build_makefile.patch"
	eapply "${FILESDIR}/build_makefile-media.patch"

	emake dir DIR="../${PF}" || die "emake failed"
	emake allyesconfig || die "emake failed"

}


src_compile() {

	# Prevent amd64 instead of x86_64 being used as system arch in linux tree #
	unset ARCH

	cd ${WORKDIR}/media_build

	emake || die "emake failed"

}


src_install() {

	# Prevent amd64 instead of x86_64 being used as system arch in linux tree #
	unset ARCH

	cd ${WORKDIR}/media_build

	elog "Installing modules..."
	emake install DESTDIR="${D}" DEST="/lib/modules/${KV_FULL}" || die "Install failed!"

	cd ${WORKDIR}

}


pkg_postinst() {

	linux-mod_pkg_postinst

	ewarn "This installs a whole new v4l kernel tree"
	ewarn "For consistency, you need to reboot after installing these modules!"

}
