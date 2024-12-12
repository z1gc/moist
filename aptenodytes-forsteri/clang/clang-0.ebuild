EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# Everything of llvm has placed into llvm-core:
DEPEND="
	llvm-core/clang
	llvm-core/lld
"
RDEPEND="${DEPEND}"

src_install() {
	unstable_mnstable
	homeinto ".config/clangd" newins "${FILESDIR}/clangd.yaml" "config.yaml"

	# TODO: other directory? such as /opt/bin, but it has lower priority.
	exeinto "/usr/local/bin"
	doexe "${FILESDIR}/"{"clang-format","clangd","intercept-build"} || die
}
