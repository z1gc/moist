EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# Language servers here as well:
DEPEND="
	app-editors/helix
	sys-devel/clang
	dev-python/python-lsp-server
	dev-util/bash-language-server
"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc/helix"
	doins -r "${FILESDIR}/." || die
}
