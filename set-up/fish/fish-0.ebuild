EAPI="8"

SLOT="0"
KEYWORDS="amd64 arm64"
S="${WORKDIR}"

# > Items which are in RDEPEND but not DEPEND could in theory be merged after
#   the target package. Portage does not currently do this.
# TODO: Fish plugins here.
RDEPEND="
	app-shells/fish
	app-shells/zoxide
	app-portage/command-not-found
"
DEPEND="${RDEPEND}"

pkg_preinst() {
	# Try to ignore the annoying `dispatch-conf`.
	rm -f "/etc/fish/config.fish"
}

src_install() {
	insinto "/etc/fish"
	doins -r "${FILESDIR}/." || die
}
