# This package should be merged in the very early stage, without any use, and
# only this package to be merged!
# It may change the really profile.

EAPI="8"

# Use is your machine, here is tricky enough to passthrough emerge.
# TODO: Have no better idea to restrict for only one use, or with other methods
#       that can separate the machine better.
# TODO: This is not very "generic" for other people to use... Huh, hard.
# Want to use the `SLOT` firstly, but the `USE` has better support.
IUSE="-moist +$(<"/etc/hostname")"
SLOT="0"

KEYWORDS="amd64 arm64"
S="${WORKDIR}"

BDEPEND="app-portage/cpuid2cpuflags"

pkg_pretend() {
	if use "moist"; then
		die "Machine can't be moist! It will make your computer blow!"
	fi
}

src_compile() {
	# In workdir:
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die
}

src_install() {
	insinto "/etc/portage"
	doins -r "${FILESDIR}/moist/." || die

	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	insinto "/etc/portage/package.use"
	doins "cpuflags" || die
}

pkg_postinst() {
	# Only in postinst do we have the "root" privilege.
	if use "evil"; then
		doins -r "${FILESDIR}/evil/." || die
		eselect profile set "default/linux/amd64/23.0/desktop/gnome/systemd" || die
	else
		die "Have no matched machine?! Maybe adding it to the overlay is needed."
	fi
}
