# This package should be merged twice!
# 1. First installation of this packages, MUST in a clean environment, and it
#    should contains less USE flags, because the first time merge will changed
#    the profile.
# 2. Use `emerge -v -UNDua @world` to re-merge this package, and making it good.
# TODO: Update the document.

EAPI="8"

# Use is your machine, here is tricky enough to passthrough emerge.
# TODO: Have no better idea to restrict for only one use, or with other methods
#       that can separate the machine better.
# TODO: This is not very "generic" for other people to use... Huh, hard.
# Want to use the `SLOT` firstly, but the `USE` has better support.
# The "-moist" use is indicating we're doing the second stage.
IUSE="+moist +$(<"/etc/hostname")"
SLOT="0"

KEYWORDS="amd64 arm64"
S="${WORKDIR}"

DEPEND="
	sys-kernel/linux-firmware
"
RDEPEND="${DEPEND}"
BDEPEND="
	moist? ( app-portage/cpuid2cpuflags )
"

src_compile() {
	if use "moist"; then
		# In workdir:
		echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die
	fi
}

src_install() {
	if use "moist"; then
		insinto "/etc/portage"
		doins -r "${FILESDIR}/moist/." || die

		# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
		insinto "/etc/portage/package.use"
		doins "cpuflags" || die
	fi
}

pkg_postinst() {
	if use "moist"; then
		# Only the first time we should change the whole system:
		if use "evil"; then
			doins -r "${FILESDIR}/evil/." || die
			eselect profile set "default/linux/amd64/23.0/desktop/gnome/systemd" || die
		else
			die "Have no matched machine?! Maybe adding it to the overlay is needed."
		fi
	fi
}
