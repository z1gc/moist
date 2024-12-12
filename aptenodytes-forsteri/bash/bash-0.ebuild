EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="app-shells/bash"
RDEPEND="${DEPEND}"

src_install() {
	unstable_mnstable
	homeinto "" newins "${FILESDIR}/bashrc" ".bashrc"
}
