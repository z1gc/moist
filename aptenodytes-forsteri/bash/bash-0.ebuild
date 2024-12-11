EAPI="8"

inherit unstable

SLOT="0"
KEYWORDS="amd64"

DEPEND="app-shells/bash"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	unstable_mnstable

	for usr in "${UNSTABLE[@]}"; do
		local home="$(eval echo "~${usr}" || die)"
		insopts "-o${usr}" "-g${usr}" "-m644"
		insinto "${home}"
		newins "${FILESDIR}/bashrc" ".bashrc"
	done
}
