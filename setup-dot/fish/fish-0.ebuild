EAPI="8"

SLOT="0"
KEYWORDS="amd64 arm64"
S="${WORKDIR}"

# > Items which are in RDEPEND but not DEPEND could in theory be merged after
#   the target package. Portage does not currently do this.
# TODO: Fish plugins here.
# May needs `dispatch-conf`.
RDEPEND="
	app-shells/fish
	app-shells/zoxide
	app-portage/command-not-found
"
DEPEND="${RDEPEND}"

src_install() {
	insinto "/etc/fish"
	doins -r "${FILESDIR}/." || die
}
