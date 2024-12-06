EAPI="8"
SLOT="0"
KEYWORDS="amd64 arm64"

if [[ "${HOSTNAME}" == "" ]]; then
	HOSTNAME="$(< "/etc/hostname")"
fi

# TODO: Like `CPU_FLAGS_X86`?
IUSE="+${HOSTNAME}"

DEPEND="
	app-admin/sudo
	dev-vcs/git
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-portage/cpuid2cpuflags
	app-eselect/eselect-repository
"

S="${WORKDIR}"

if [[ -f "${FILESDIR}/machine/${HOSTNAME}" ]]; then
	source "${FILESDIR}/machine/${HOSTNAME}"
fi

src_compile() {
	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die
	echo "pygocelis-papua/* ${HOSTNAME}" > "pygocelis-papua" || die

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	insinto "/etc/portage/package.use"
	doins "pygocelis-papua" "cpuflags" || die

	insinto "/etc/portage"
	doins -r "${FILESDIR}/conf/." || die

	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_postinst() {
	# Profile
	if [[ "${PROFILE}" != "" ]]; then
		eselect profile set "${PROFILE}" || die
	fi

	# Reset the moist:
	eselect repository remove moist || die
	eselect repository add moist git https://github.com/z1gc/moist

	# New repository:
	eselect repository enable gentoo-zh || die
	eselect repository enable guru || die

	# systemd setup, TODO: ensure we have systemd at first?
	# TODO: eclass?
	systemd-machine-id-setup || die
	systemd-firstboot --hostname="${HOSTNAME}" --timezone="Asia/Shanghai" || die
	systemctl preset-all --preset-mode=enable-only || die
}

pkg_postrm() {
	# TODO: systemd units.
	eselect repository remove moist
	eselect repository remove gentoo-zh
	eselect repository remove guru
}
