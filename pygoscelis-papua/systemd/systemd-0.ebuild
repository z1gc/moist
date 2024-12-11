EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
DEPEND="sys-apps/systemd"
RDEPEND="${DEPEND}"

pkg_postinst() {
	unstable_mnstable

	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${MNSTABLE}" --timezone="Asia/Shanghai" || die
	fi

	# systemctl list-unit-files --state=enabled
	systemctl preset getty@tty1.service \
									 systemd-boot-update.service \
									 systemd-resolved.service \
									 systemd-timesyncd.service \
									 systemd-journald-audit.socket \
									 systemd-mountfsd.socket \
									 systemd-nsresourced.socket \
									 systemd-userdbd.socket \
									 machines.target \
									 reboot.target \
									 remote-fs.target || die

	# Other services that is preset but keep them disabled:
	# systemd-confext.service
	# systemd-pstore.service
	# systemd-sysext.service
	# systemd-networkd.service
}
