EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

# The order of merging isn't deterministic, therefore we can't make any
# assumptions.
DEPEND="
	aptenodytes-forsteri/ccache
	sys-kernel/gentoo-kernel
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	# only need once:
	bootctl install || die
}
