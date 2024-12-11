EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
DEPEND="sys-apps/systemd"
RDEPEND="${DEPEND}"

pkg_postinst() {
	unstable_mnstable

	for usr in "${UNSTABLE[@]}"; do
		# Only systemd services, other service should be installed by themselves.
		systemctl --user -M "${usr}@" preset systemd-tmpfiles-setup.service \
																				 systemd-tmpfiles-clean.timer || die
	done
}
