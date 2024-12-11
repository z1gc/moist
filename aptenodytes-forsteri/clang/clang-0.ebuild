EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="
	sys-devel/clang
	sys-devel/lld
"
RDEPEND="${DEPEND}"

src_install() {
	unstable_mnstable
	homeinto ".config/clangd" newins "${FILESDIR}/clangd.yaml" "config.yaml"
}
