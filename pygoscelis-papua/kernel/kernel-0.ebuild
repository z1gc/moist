EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# The order of merging isn't deterministic, therefore we can't make any
# assumptions.
# FIXME: It may leads to gentoo-kernel compilation failure when the dependencies
# order is reversed.
DEPEND="
	aptenodytes-forsteri/ccache
	sys-kernel/linux-firmware
	sys-kernel/gentoo-kernel
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	# only need once:
	bootctl install || die
}
