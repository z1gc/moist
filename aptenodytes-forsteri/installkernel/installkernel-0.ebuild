EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="
	sys-kernel/installkernel
	sys-fs/btrfs-progs
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-apps/util-linux
	sys-devel/gettext
"

S="${WORKDIR}"

pkg_pretend() {
	if [[ "$(stat -f -c %T /)" != "btrfs" ]]; then
		die "Why not BTRFS? Do you hate it? Oh, that's fine :)"
	fi
}

src_compile() {
	# cmdline based on btrfs subvolume, it should be like (btrfs subvolume list):
	# > ID 256 gen 506217 top level 5 path @gentoo
	# > ID 259 gen 508237 top level 256 path @gentoo/var
  # > ID 257 gen 506227 top level 5 path @home
  # > ID 258 gen 509452 top level 5 path @snapshots
	# ...
	# https://wiki.archlinux.org/title/Snapper#Suggested_filesystem_layout

	# fstab:
	# <dev> / btrfs subvolid=256 0 0
	# <dev> /home btrfs subvolid=257 0 0
	# <dev> /efi vfat utf8,codepage=936 0 2
	# <dev> none swap defaults 0 0
	local fsdev
	local subvolid

	cp "${FILESDIR}/unstable/fstab" "fstab"
	for subvol in "/" "/home"; do
		# TODO: use blk uuid?
		fsdev="$(findmnt --real -v -o SOURCE -n -M "${subvol}" \
					   || die "Missing volume ${subvol}, is it really mounted?")"
		subvolid="$(btrfs inspect-internal rootid "${subvol}" || die)"

		if [[ "${subvol}" == "/" ]]; then
			ROOTFS="${fsdev}" SUBVOLID="${subvolid}" \
				envsubst < "${FILESDIR}/unstable/cmdline" > "cmdline"
		fi

		echo -e "${fsdev}\t${subvol}\tbtrfs\tsubvolid=${subvolid}\t0\t0"
	done >> "fstab"

	# support for legacy /boot part:
	for subvol in "/efi" "/boot/efi"; do
		fsdev="$(findmnt --real -v -o SOURCE -n -M "${subvol}")"
		if [[ "${fsdev}" != "" ]]; then
			echo -e "${fsdev}\t${subvol}\tvfat\tutf8,codepage=936\t0\t2" >> "fstab"
			break
		fi
	done

	if [[ "${fsdev}" == "" ]]; then
		die "Missing EFI boot partition, is it really mounted?"
	fi

	# try swap TODO: better way?
	fsdev="$(lsblk -o NAME,MOUNTPOINTS -p -r | awk '$2 == "[SWAP]" {print $1}')"
	if [[ "${fsdev}" != "" ]]; then
		echo -e "${fsdev}\tnone\tswap\tdefaults\t0\t0" >> "fstab"
	fi
}

src_install() {
	unstable_mnstable

	insinto "/etc/kernel"
	doins "${FILESDIR}/unstable/install.conf" "cmdline"
	for comp in $(use_directory "config.d"); do
		doins -r "${comp}"
	done

	insinto "/etc"
	doins "fstab"
}

pkg_preinst() {
	rm_if_diff "/etc/fstab"
}
