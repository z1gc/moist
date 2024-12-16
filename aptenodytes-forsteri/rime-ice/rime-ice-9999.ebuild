EAPI="8"

# TODO: Move this package into standalone package?
# e.g. https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=rime-ice-git
inherit unstable git-r3

MNSTABLE=("evil")
UNSTABLE=("byte")

SLOT="0"
KEYWORDS="amd64"
LICENSE="GPL-3"

DEPEND="
	app-i18n/ibus-rime
	app-i18n/librime-lua
"
RDEPEND="${DEPEND}"

EGIT_REPO_URI="https://github.com/iDvel/rime-ice.git"

src_install() {
	unstable_mnstable

	# Cleanup:
	rm -rf ./.git* \
				 "others" \
				 "LICENSE" \
				 "README.md"

	homeinto ".config/ibus/rime" doins -r "."
	homeinto ".config/ibus/rime" doins -r "${FILESDIR}/."
}
