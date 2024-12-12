EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="
	dev-lang/go
	dev-go/gopls
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

go_doins() {
	# homeinto should set $HOME:
	envsubst < "${1}" > "env"
	doins "env"
}

src_install() {
	unstable_mnstable
	homeinto ".config/go" go_doins "${FILESDIR}/env"
}
