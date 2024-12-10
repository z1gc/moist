EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

# > Items which are in RDEPEND but not DEPEND could in theory be merged after
#   the target package. Portage does not currently do this.
DEPEND="
	app-shells/fish
	app-shells/fish-autols
	app-shells/fish-fzf
	app-shells/fish-upto
	app-shells/zoxide
	app-portage/command-not-found
"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc/fish"
	doins -r "${FILESDIR}/." || die
}

pkg_preinst() {
	# Try to ignore the annoying `dispatch-conf`.
	rm_if_diff -f "/etc/fish/config.fish"
}
