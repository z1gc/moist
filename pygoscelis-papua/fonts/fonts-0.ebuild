EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}"

DEPEND="
	media-libs/fontconfig
	media-fonts/liberation-fonts
	media-fonts/noto
	media-fonts/noto-emoji
	media-fonts/sarasa-gothic
	media-fonts/source-han-sans
	media-fonts/wqy-microhei
	media-fonts/wqy-zenhei
"
RDEPEND="${DEPEND}"

src_install() {
	insinto "/etc/fonts/conf.avail"
	doins -r "${FILESDIR}/." || die
}

pkg_postinst() {
	# Fonts are special, we handle EVERY fonts in here, for simplicity.
	# TODO: Make a "unstable-service" or else to handle every systemd service as
	#       well?
	for config in $(eselect fontconfig list \
									| awk '$3 == "*" && $2 ~ /\.conf$/ {print $2}')
	do
		eselect fontconfig disable "${config}" || die
	done

	# Re-enable what we want
	eselect fontconfig enable 10-hinting-slight.conf \
														10-scale-bitmap-fonts.conf \
														10-sub-pixel-bgr.conf \
														10-yes-antialias.conf \
														11-lcdfilter-default.conf \
														30-metric-aliases.conf \
														45-generic.conf \
														48-spacing.conf \
														49-sansserif.conf \
														50-user.conf \
														51-local.conf \
														60-generic.conf \
														70-noto-cjk.conf \
														75-noto-emoji-fallback.conf \
														90-synthetic.conf || die
}
