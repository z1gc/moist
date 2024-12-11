EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="net-libs/nodejs"
RDEPEND="${DEPEND}"

src_install() {
	unstable_mnstable
	homeinto "" newins "${FILESDIR}/npmrc" ".npmrc"
}
