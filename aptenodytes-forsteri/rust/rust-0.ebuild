EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="
	dev-lang/rust-bin
	sys-devel/ra-multiplex
"
RDEPEND="${DEPEND}"

src_install() {
	exeinto "/usr/local/bin"
	doexe "${FILESDIR}/rust-analyzer" || die
}
