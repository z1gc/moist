# This ebuild only configures the portage, setting up what packages will be
# installed, and what USE should be choosed depend on hostname.
#
# Hmmm, it also configures the installkernel, to avoid wrong dependency...
#
# TabSize=2

EAPI="8"

inherit unstable

KEYWORDS="amd64"
SLOT="0"
S="${WORKDIR}"

# To ensure the installkernel configurations set up, we make it depends.
DEPEND="
	aptenodytes-forsteri/installkernel
	app-admin/sudo
"
RDEPEND="${DEPEND}"
BDEPEND="app-portage/cpuid2cpuflags"

src_compile() {
	unstable_mnstable

	# world and set, gentoo will sort it then :)
	for comp in $(use_directory "world"); do
		grep -o '^[^#]*' "${comp}" || die
	done | sort > "world"
	echo "" > "world_sets"

	# Share to everybody, huh, seems unneccessary to split two groups.
	local u="${USESTABLE[*]} UNSTABLE: ${UNSTABLE[*]} MNSTABLE: ${MNSTABLE[*]}"
	( echo "pygoscelis-papua/* ${u}"
		echo "aptenodytes-forsteri/* ${u}"
	) > "mnstable"

	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
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
	#   /make.conf, ...: /etc/portage
	#
	# IMO the package.accept_keywords and package.license are irrelavent to any
	# machine, it has smallest side effect on merging packages. And the repos.conf
	# and patches are now all in just one unstable, but not others now.
	# Just extract what you really want.
	insinto "/etc/portage"
	for comp in "binrepos.conf" \
							"mirrors" \
						  "package.accept_keywords" \
						  "package.license" \
						  "patches" \
						  "repos.conf"; do
		doins -r "${FILESDIR}/unstable/${comp}"
	done
	for comp in $(use_directory "make.conf" \
															"package.use"); do
		doins -r "${comp}" || die
	done

	# This will give an error of overwriting things we shouldn't, but safe yet.
	insinto "/var/lib/portage"
	doins "world" "world_sets"

	# locale, TODO: to other ebuild?
	insinto "/etc"
	doins "${FILESDIR}/unstable/locale.gen"

	insinto "/etc/sudoers.d"
	insopts "-m440"
	doins "wheel" || die
}

pkg_preinst() {
	# remove existing files, don't want an extra dispatch-conf
	rm_if_diff /etc/portage/binrepos.conf/gentoobinhost.conf
	rm_if_diff /etc/portage/repos.conf/gentoo.conf
	rm_if_diff /etc/portage/repos.conf/unstable.conf
	rm_if_diff /etc/locale.gen
}

pkg_postinst() {
	unstable_mnstable

	# profile
	local profile="default/linux/amd64/23.0/systemd"
	if use "gnome"; then
		profile="default/linux/amd64/23.0/desktop/gnome/systemd"
	fi

	ewarn "New eselect profile: ${profile}"
	eselect profile set "${profile}" || die

	# locale
	locale-gen || die

	einfo 'Run $(emerge -va -UNDu @world) for the next step.'
}
