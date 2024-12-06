EAPI="8"
SLOT="0"
KEYWORDS="amd64 arm64"

if [[ "${HOSTNAME}" == "" ]]; then
	HOSTNAME="$(< "/etc/hostname")"
fi

# This is just an indicator, telling you which machine is selected.
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

src_compile() {
	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# generate make.conf:
	python3 "${FILESDIR}/fx" "${FILESDIR}/templ/build.conf" "${FILESDIR}/${HOSTNAME}/build"

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	insinto "/etc/portage/package.use"
	doins "cpuflags" || die

	insinto "/etc/portage"
	doins -r "${FILESDIR}/conf/." "${FILESDIR}/${HOSTNAME}/conf/." || die

	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_postinst() {
	# Profile:
	eselect profile set "$(< "${FILESDIR}/${HOSTNAME}/profile")" || die

	# New repository:
	eselect repository enable gentoo-zh || die
	eselect repository enable guru || die

	# systemd setup, TODO: ensure we have systemd at first?
	# TODO: eclass?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${HOSTNAME}" --timezone="Asia/Shanghai" || die
		systemctl preset-all --preset-mode=enable-only || die
	fi
}
