EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="
	sys-apps/systemd
	gnome? ( gnome-base/gnome-light )
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	unstable_mnstable

	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${MNSTABLE}" --timezone="Asia/Shanghai" || die
	fi

	# TODO: elegant way?
	local units="$(systemctl list-unit-files --state enabled \
								 | awk '$1 ~ /.+\..+/ {print $1}')"
	if [[ "${units}" != "" ]]; then
		systemctl disable "${units}"
	fi

	# find presets: systemctl list-unit-files
	systemctl preset getty@.service \
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

	if use "gnome"; then
		systemctl preset gdm.service \
										 NetworkManager.service \
										 NetworkManager-wait-online.service \
										 NetworkManager-dispatcher.service || die
	else
		systemctl preset systemd-networkd.service \
										 systemd-networkd-wait-online.service || die
	fi

	# Other services that is preset but keep them disabled:
	# systemd-confext.service
	# systemd-pstore.service
	# systemd-sysext.service
	# systemd-network-generator.service
}
