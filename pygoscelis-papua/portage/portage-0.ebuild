# This ebuild only configures the portage, setting up what packages will be
# installed, and what USE should be choosed depend on hostname.
#
# Okay, I've lied, it also setup the systemd, that' all, really :O
#
# TabSize=2

EAPI="8"

inherit unstable

KEYWORDS="amd64"
SLOT="0"

DEPEND="
	sys-apps/systemd
	app-admin/sudo
"
RDEPEND="${DEPEND}"
BDEPEND="app-portage/cpuid2cpuflags"

S="${WORKDIR}"

src_compile() {
	unstable_mnstable

	# world and set, gentoo will sort it then :)
	for comp in $(use_directory "world"); do
		grep -o '^[^#]*' "${comp}" || die
	done | sort > "world"
	echo "" > "world_sets"

	# Setting both MNSTABLE and UNSTABLE for portage, to avoid inconsistency when
	# upgrading through emerge.
	# TODO: Place the special portage to other places?
	( echo "pygoscelis-papua/* ${USESTABLE[*]} MNSTABLE: ${MNSTABLE[*]}"
		echo "pygoscelis-papua/portage UNSTABLE: ${UNSTABLE[*]}"
		echo "aptenodytes-forsteri/* UNSTABLE: ${UNSTABLE[*]}"
	) > "mnstable"

	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	unstable_mnstable

	insinto "/etc/portage/package.use"
	doins "mnstable" "cpuflags" || die

	# For machine, the {rest} part should contains:
	#   /use: The USE flags that it's using
	#   /user: The main user that unstable controls (TODO: Multiuser?)
	# Machine is also an USE, although it never shows up in the IUSE.
	#
	# And the common {rest} part:
	#   /world: What this USE brings up to the world.
	#   /profile: This USE will require the eselect profile.
	#   /make.conf, ...: /etc/portage
	insinto "/etc/portage"
	for comp in $(use_directory "binrepos.conf") \
							$(use_directory "make.conf") \
							$(use_directory "package.accept_keywords") \
							$(use_directory "package.license") \
							$(use_directory "package.use") \
							$(use_directory "repos.conf")
	do
		doins -r "${comp}" || die
	done

	# This will give an error of overwriting things we shouldn't, but safe yet.
	insinto "/var/lib/portage"
	doins "world" "world_sets"

	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_preinst() {
	# remove existing files, don't want an extra dispatch-conf
	rm_if_diff /etc/portage/binrepos.conf/gentoobinhost.conf
	rm_if_diff /etc/portage/repos.conf/unstable.conf
}

pkg_postinst() {
	unstable_mnstable

	# profile
	for comp in $(use_directory "profile"); do
		local profile="$(< "${comp}")"
		ewarn "New eselect profile: ${profile}"
		eselect profile set "${profile}"
		break
	done

	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${MNSTABLE}" --timezone="Asia/Shanghai" || die
		systemctl preset-all --preset-mode=enable-only || die
	fi

	einfo 'Run $(emerge -va -UNDu @world) for the next step.'
}
