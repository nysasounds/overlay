# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="TBS DVB Cards Firmware"
HOMEPAGE="https://github.com/tbsdtv/linux_media"

SRC_URI="https://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v${PV}.tar.bz2 -> ${P}.tar.bz2"


LICENSE="TurboSight Proprietary"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="strip"
QA_PREBUILT="lib/firmware/*"

DEPEND=""
RDEPEND="virtual/linux-sources"
BDEPEND=""

S="${WORKDIR}"

FIRMWARE_EXCLUDES=(
	dvb-fe-xc4000-1.4.1.fw
	dvb-fe-xc5000-1.6.114.fw
	dvb-fe-xc5000c-4.1.30.7.fw
	dvb-usb-dib0700-1.20.fw
	dvb-usb-it9135-01.fw
	dvb-usb-it9135-02.fw
	dvb-usb-terratec-h5-drxk.fw
	sms1xxx-hcw-55xxx-dvbt-02.fw
	sms1xxx-hcw-55xxx-isdbt-02.fw
	sms1xxx-nova-a-dvbt-01.fw
	sms1xxx-nova-b-dvbt-01.fw
	sms1xxx-stellar-dvbt-01.fw
	v4l-cx231xx-avcore-01.fw
	v4l-cx23418-apu.fw
	v4l-cx23418-cpu.fw
	v4l-cx23418-dig.fw
	v4l-cx23885-avcore-01.fw
	v4l-cx25840.fw
)


src_install() {

	elog "Installing firmware..."

	elog "Excluding already provided firmware:"
	for fw in ${FIRMWARE_EXCLUDES[@]} ; do
		elog $(rm -fv ${fw})
	done
	elog "Firmware exclusions done"

	insinto /lib/firmware/
	doins * || die "Install firmware failed!"

}


pkg_postinst() {

	ewarn "TBS firmware is proprietary and closed source"

}
