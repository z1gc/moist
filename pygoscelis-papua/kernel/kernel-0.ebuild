EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

# Should setup the installkernel firstly, then merge the gentoo kernel.
# TODO: Will this order be determined?
DEPEND="
	pygoscelis-papua/installkernel
	sys-kernel/gentoo-kernel
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	# only need once:
	bootctl install || die
}
