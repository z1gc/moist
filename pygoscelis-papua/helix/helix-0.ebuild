EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# TODO: Language servers here?
DEPEND="
	app-editors/helix
"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc/helix"
	doins -r "${FILESDIR}/." || die
}
