EAPI="8"

inherit git-r3

SLOT="0"
KEYWORDS="~amd64"
LICENSE="MIT"

EGIT_REPO_URI="https://github.com/Markcial/upto.git"

src_install() {
  insinto "/etc/fish"
  doins -r "completions" "functions"
}
