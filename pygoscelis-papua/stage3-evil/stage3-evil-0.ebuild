# Should follow what system defined Stage 3.

EAPI="8"
SLOT="0"
KEYWORDS="amd64 arm64"

pkg_postinst() {
	eselect profile set "default/linux/amd64/23.0/desktop/gnome/systemd" || die
}
