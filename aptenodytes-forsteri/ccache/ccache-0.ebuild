EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="dev-util/ccache"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc"
	doins "${FILESDIR}/ccache.conf" || die
}
