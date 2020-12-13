# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 linux-mod

DESCRIPTION="TBS DVB Card drivers [ Open Source ] - this includes a whole new V4L tree"
HOMEPAGE="https://github.com/tbsdtv/linux_media"

LINUX_MEDIA_EGIT_REPO_URI="https://github.com/tbsdtv/linux_media.git"
LINUX_MEDIA_EGIT_BRANCH="latest"

MEDIA_BUILD_EGIT_REPO_URI="https://github.com/tbsdtv/media_build.git"
MEDIA_BUILD_EGIT_BRANCH="master"

EGIT_CLONE_TYPE="shallow"
EGIT_MIN_CLONE_TYPE="shallow"

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


S="${WORKDIR}/media_build"


src_unpack() {

	git-r3_fetch ${LINUX_MEDIA_EGIT_REPO_URI} refs/heads/${LINUX_MEDIA_EGIT_BRANCH}
	git-r3_checkout ${LINUX_MEDIA_EGIT_REPO_URI} "${WORKDIR}/media"

	git-r3_fetch ${MEDIA_BUILD_EGIT_REPO_URI} refs/heads/${MEDIA_BUILD_EGIT_BRANCH}
	git-r3_checkout ${MEDIA_BUILD_EGIT_REPO_URI} "${WORKDIR}/media_build"

}


src_prepare() {

	# lsmod path and remove unwanted depmod #
	eapply "${FILESDIR}/build_makefile.patch"
	eapply "${FILESDIR}/build_makefile-media.patch"
	# https://www.tbsdtv.com/forum/viewtopic.php?f=87&t=25419&start=10#p55682
	eapply "${FILESDIR}/build_v4l_versions.patch"

	# Set target kernel version #
	echo "VERSION = ${KV_MAJOR}" > v4l/.version
	echo "PATCHLEVEL = ${KV_MINOR}" >> v4l/.version
	echo "SUBLEVEL = ${KV_PATCH}" >> v4l/.version
	echo "EXTRAVERSION = ${KV_EXTRA}" >> v4l/.version
	echo "KERNELRELEASE:=${KV_FULL}" >> v4l/.version

	eapply_user

}


src_configure() {

	# Prevent amd64 instead of x86_64 being used as system arch in linux tree #
	unset ARCH

	# Setup and configure #
	#emake dir DIR="../${PF}" || die "emake dir failed"
	emake dir DIR="../media" || die "emake dir failed"
	emake allyesconfig || die "emake config failed"

}


src_compile() {

	emake || die "emake failed"

}


src_install() {

	elog "Installing modules..."
	emake install DESTDIR="${D}" DEST="/lib/modules/${KV_FULL}" || die "Install failed!"

}


pkg_postinst() {

	linux-mod_pkg_postinst

	ewarn "This installs a whole new v4l kernel tree"
	ewarn "For consistency, you need to reboot after installing these modules!"

}
