EAPI="8"
SLOT="0"
KEYWORDS="amd64 arm64"

DEPEND="app-admin/sudo"
RDEPEND="${DEPEND}"
BDEPEND="
	app-portage/cpuid2cpuflags
	app-eselect/eselect-repository
"

if [[ -f "/var/db/moist/user" ]]; then
	DEPEND+=" acct-user/$(< "/var/db/moist/user")"
elif [[ "${MOIST_USER}" != "" ]]; then
	DEPEND+=" acct-user/${MOIST_USER}"
else
	# TODO: Support multiple user?
	die "No target user can be found!"
fi

if [[ -f "/var/db/moist/host" ]]; then
	DEPEND+=" pygoscelis-papua/stage3-$(< "/var/db/moist/host")"
elif [[ "${MOIST_HOST}" != "" ]]; then
	DEPEND+=" pygoscelis-papua/stage3-${MOIST_HOST}"
else
	die "No target host can be found!"
fi

S="${WORKDIR}"

src_compile() {
	# For following installation:
	echo "${MOIST_USER}" > "user"
	echo "${MOIST_HOST}" > "host"

	# cpuflags
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	insinto "/var/db/moist"
	doins "user" "host" || die

	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	insinto "/etc/portage/package.use"
	doins "cpuflags" || die

	# uses
	insinto "/etc/portage"
	doins -r "${FILESDIR}/." || die

	# sudo
	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_postinst() {
	# New repository:
	eselect repository enable gentoo-zh
	eselect repository enable guru

	# systemd setup, TODO: ensure we have systemd at first?
	# TODO: eclass?
	systemd-machine-id-setup || die
	systemd-firstboot --hostname="${MOIST_HOST}" --timezone="Asia/Shanghai" || die
	systemctl preset-all --preset-mode=enable-only || die
}

pkg_postrm() {
	# TODO: systemd units.
	eselect repository disable gentoo-zh
	eselect repository disable guru
}
