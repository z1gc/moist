EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# Language servers here as well:
DEPEND="
	app-editors/helix
	aptenodytes-forsteri/clang
	aptenodytes-forsteri/rust
	aptenodytes-forsteri/go
	dev-python/python-lsp-server
	dev-util/bash-language-server
	dev-util/lua-language-server
"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc/helix"
	doins -r "${FILESDIR}/." || die
}
