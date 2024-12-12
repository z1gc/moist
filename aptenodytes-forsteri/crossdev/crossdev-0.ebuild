EAPI="8"

inherit unstable

# Crossdev here is just a wrapper, it won't prepare the real crossdev for you,
# the compiling process is too complex to use just one emerge to install.
#
# This repository is just set up a simple crossdev repository, for furthur usage
# you should check out the Gentoo wiki. But you can start "crossdev" directly
# if you merged this package, will not suffer from setting the repository stuff.
#
# https://wiki.gentoo.org/wiki/Crossdev

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="sys-devel/crossdev"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/var/db/repos/crossdev"
	doins -r "${FILESDIR}/."
}
