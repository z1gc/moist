EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="
	sys-apps/systemd
	app-admin/sudo
	gnome? (
		gnome-base/gnome-light
		media-libs/libpulse
		media-video/pipewire
		media-video/wireplumber
	)
"
RDEPEND="${DEPEND}"
BDEPEND="sys-apps/findutils"

system_postinst() {
	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${MNSTABLE}" --timezone="Asia/Shanghai" || die
	fi

	# Make sure the systemd's clean.
	systemctl list-unit-files --state enabled | awk '$1 ~ /.+\..+/ {print $1}' \
		| xargs -r systemctl disable || die

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
		systemctl preset NetworkManager.service \
										 NetworkManager-wait-online.service \
										 NetworkManager-dispatcher.service || die
		systemctl enable gdm.service || die
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

user_postinst() {
	# user here:
	for usr in "${UNSTABLE[@]}"; do
		# the systemd seems ignoring the -M user, and still using $HOME:
		local systemctl="sudo -u ${usr} systemctl --user"

		# won't double quote the $systemctl, we let it escape:
		${systemctl} list-unit-files --state enabled \
			| awk '$1 ~ /.+\..+/ {print $1}' | xargs -r ${systemctl} disable || die

		${systemctl} preset pipewire.service \
								 pipewire.socket \
								 pipewire-pulse.service \
								 pipewire-pulse.socket \
								 wireplumber.service \
								 systemd-tmpfiles-setup.service \
								 systemd-tmpfiles-clean.timer || die
	done
}

pkg_postinst() {
	unstable_mnstable
	system_postinst
	user_postinst
}
