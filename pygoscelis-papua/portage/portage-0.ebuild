# This ebuild only configures the portage, setting up what packages will be
# installed, and what USE should be choosed depend on hostname.
#
# Okay, I've lied, it also setup the systemd, that' all, really :O

EAPI="8"
KEYWORDS="amd64"
SLOT=""

if [[ "${SLOT}" == "" ]]; then
	die "SLOT should be there!"
fi

IUSE="+moist +${SLOT} $(< "${FILESDIR}/${SLOT}/use")"
MOIST_USER="$(< "${FILESDIR}/${SLOT}/user")"

DEPEND="
	acct-user/${MOIST_USER}
	sys-apps/systemd
	app-admin/sudo
"
RDEPEND="${DEPEND}"
BDEPEND="app-portage/cpuid2cpuflags"

S="${WORKDIR}"

src_compile() {
	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# world and set, gentoo will sort it then :)
	for comp in "${FILESDIR}/"*; do
		local name="$(basename "${comp}")"
		if [[ ! -f "${comp}/world" ]] || ! use "${name}"; then
			continue
		fi

		SLOT_USER="${MOIST_USER}" SLOT_HOST="{SLOT}" envsubst < "${comp}/world"
	done > "world"
	grep -o '^[^#]*' "world" | sort | sponge "world"
	echo "" > "world_sets"

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	insinto "/etc/portage/package.use"
	doins "cpuflags" || die

	insinto "/etc/portage"
	doins -r "${FILESDIR}/conf/." || die

	insinto "/etc/portage/make.conf"
	for comp in "${FILESDIR}/"*; do
		local name="$(basename "${comp}")"
		if [[ ! -d "${comp}/make.conf" ]] || ! use "${name}"; then
			test
		fi

		doins -r "${comp}/make.conf/." || die
	done

	insinto "/var/lib/portage"
	doins "world" "world_sets"

	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_postinst() {
	# profile
	for comp in "${FILESDIR}/"*; do
		local name="$(basename "${comp}")"
		if [[ ! -f "${comp}/profile" ]] || ! use "${name}"; then
			continue
		fi

		eselect profile "$(< "${comp}/profile")"
		break
	done

	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${SLOT}" --timezone="Asia/Shanghai" || die
		systemctl preset-all --preset-mode=enable-only || die
	fi
}
