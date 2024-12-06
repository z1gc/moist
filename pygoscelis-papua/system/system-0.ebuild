# Stage 3:
# - We're in Gentoo's stage 3.
# - Setup portage, install USE flags or else.
# - Install profile.
# - Bringup systemd-firstboot.
# - Create specified user.
#
# Stage 4:
# - Install linux-firmware.
# - Create boot loader.
# - Create a world set.
#
# Stage 5:
# - Install everything else.
# - The Stage 5 is within the world set `@moist-world`.
# - TODO: Moist to Mist? I like moi (or moe) :)
#
# This is a virtual package, but not in virtual (huh).
#
# TODO: This is not very "generic" for other people to use... Huh, hard.
# Want to use the `SLOT` firstly, but the `USE` has better support.

EAPI="8"
SLOT="0"
IUSE="+stage3 stage4"
KEYWORDS="amd64 arm64"

RDEPEND="
	stage3? ( pygoscelis-papua/stage3 )
	stage4? ( pygoscelis-papua/stage4 )
"

S="${WORKDIR}"

src_compile() {
	local stages=()
	use "stage3" && stages+=("stage4")
	echo "pygoscelis-papua/system ${stages[*]}" > "system"
}

src_install() {
	insinto "/etc/portage/package.use"
	doins "system" || die
}
