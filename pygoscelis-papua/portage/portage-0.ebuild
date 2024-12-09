# This ebuild only configures the portage, setting up what packages will be
# installed, and what USE should be choosed depend on hostname.
#
# Okay, I've lied, it also setup the systemd, that' all, really :O
#
# TabSize=2

EAPI="8"
KEYWORDS="amd64"
SLOT="$(< "/etc/hostname")"

# Can't use FILESDIR in here, therefore a fixed ebuild direcotry is using...
# Ugly, and TODO may never be done...
EBUILDDIR="${BASH_SOURCE[0]%/*}/files"
UNSTABLE_USER="$(< "${EBUILDDIR}/${SLOT}/user")"

IUSE="$(< "${EBUILDDIR}/${SLOT}/use")"
DEPEND="
	acct-user/${UNSTABLE_USER}
	sys-apps/systemd
	app-admin/sudo
"
RDEPEND="${DEPEND}"
BDEPEND="app-portage/cpuid2cpuflags"

S="${WORKDIR}"

use_directory() {
	local filter="$1"

	for comp in "${FILESDIR}/"*; do
		local name="$(basename "${comp}")"
		case "${name}" in
		"unstable"|"${SLOT}")
			# no-op
		;;
		*)
			use "${name}" || continue
		;;
		esac

		if [[ ! -e "${comp}/${filter}" ]]; then
			continue
		fi

		echo "${comp}/${filter}"
	done
}

src_compile() {
	# https://wiki.gentoo.org/wiki/CPU_FLAGS_*
	echo "*/* $(cpuid2cpuflags)" > "cpuflags" || die

	# world and set, gentoo will sort it then :)
	for comp in $(use_directory "world"); do
		SLOT_USER="${UNSTABLE_USER}" SLOT_HOST="${SLOT}" envsubst < "${comp}" || die
	done > "world.tmp"
	grep -o '^[^#]*' "world.tmp" | sort > "world"
	echo "" > "world_sets"

	# sudo
	echo "%wheel ALL=(ALL:ALL) ALL" > "wheel" || die
	chmod 0640 "wheel" || die
}

src_install() {
	insinto "/etc/portage/package.use"
	doins "cpuflags" || die

	# TODO: Merge into one directory before install?
	insinto "/etc/portage"
	for comp in $(use_directory "binrepos.conf") \
							$(use_directory "make.conf") \
							$(use_directory "package.accept_keywords") \
							$(use_directory "package.license") \
							$(use_directory "package.use")
	do
		doins -r "${comp}" || die
	done

	# This will give an error of overwriting things we shouldn't, but safe yet.
	insinto "/var/lib/portage"
	doins "world" "world_sets"

	insinto "/etc/sudoers.d"
	doins "wheel" || die
}

pkg_postinst() {
	# profile
	for comp in $(use_directory "profile"); do
		eselect profile set "$(< "${comp}")"
		break
	done

	# systemd setup, TODO: ensure we have systemd at first?
	if [[ ! -f /etc/machine-id ]]; then
		systemd-machine-id-setup || die
		systemd-firstboot --hostname="${SLOT}" --timezone="Asia/Shanghai" || die
		systemctl preset-all --preset-mode=enable-only || die
	fi
}
