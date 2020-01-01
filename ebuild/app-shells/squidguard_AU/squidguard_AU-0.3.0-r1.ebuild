# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: https://raw.githubusercontent.com/jaypeche/SquidGuarg_AU/master/ebuild/app-shells/squidguard_AU/squidguard_AU-0.3.0-r1.ebuild jay Ext $

EAPI=4

inherit eutils systemd

DESCRIPTION="Auto-update script for SquidGuard database"
HOMEPAGE="https://github.com/jaypeche/SquidGuarg_AU"

SRC_URI="http://www.pingwho.org/pub/gentoo/ftp/overlay/distfiles/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-cron -systemd"

RESTRICT="nomirror"

DEPEND=">=net-proxy/squid-3.3.13
	>=net-proxy/squidguard-1.4-r4
	cron? ( virtual/cron )
	systemd? ( sys-apps/gentoo-systemd-integration
        >=sys-apps/systemd-204-r1 )"

PREFIX="/usr/sbin"
CRON_TASK="/etc/cron.weekly"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if use systemd; then
		epatch "${FILESDIR}/${P}-gentoo-systemd.diff" || die "epatch failed" !
	fi
}

src_install() {
	einfo "Install shell script into sbin path..."
	dosbin ${PREFIX}/squidguard_AU.sh || die "dosbin failed !"

	if use cron; then
		einfo "Install symlink for cron.weekly task..."
		dosym ${PREFIX}/${PN}.sh ${CRON_TASK}/${PN}.sh || die "dosym failed"
	fi

	if use systemd ; then
		einfo "Install Squid systemd unit..."
		systemd_dounit "${FILESDIR}/squid.service" || die "dounit failed !"
	fi

	dodoc ChangeLog Copying README || die "dodoc failed !"
}

pkg_postinst() {
	einfo
	einfo "Now, you should run squidguard_AU manually,"
	einfo "to see if this script running correctly with your ACL configuration"
	einfo "# sh /usr/sbin/squidguard_AU.sh"
	einfo
}

