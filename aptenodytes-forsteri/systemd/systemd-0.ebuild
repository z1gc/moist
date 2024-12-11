EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="
	sys-apps/systemd
	gnome? (
		media-libs/libpulse
		media-video/pipewire
		media-video/wireplumber
	)
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	unstable_mnstable

	for usr in "${UNSTABLE[@]}"; do
		local systemctl="systemctl --user -M ${usr}@"

		# TODO: elegant way?
		local units="$($systemctl list-unit-files --state enabled \
									 | awk '$1 ~ /.+\..+/ {print $1}')"
		if [[ "${units}" != "" ]]; then
			$systemctl disable "${units}"
		fi

		$systemctl "${usr}@" preset pipewire.service \
												 pipewire.socket \
												 pipewire-pulse.service \
												 pipewire-pulse.socket \
												 wireplumber.service \
												 systemd-tmpfiles-setup.service \
												 systemd-tmpfiles-clean.timer || die
	done
}
