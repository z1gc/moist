EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="
	net-libs/nodejs
	sys-apps/yarn
"
RDEPEND="${DEPEND}"

src_install() {
	unstable_mnstable
	homeinto "" newins "${FILESDIR}/npmrc" ".npmrc"
}
