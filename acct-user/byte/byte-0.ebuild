EAPI="8"

inherit acct-user

BDEPEND="dev-libs/openssl"

ACCT_USER_ID="1000"
ACCT_USER_ENFORCE_ID="yes"
ACCT_USER_SHELL="/bin/bash"
ACCT_USER_HOME="/home/${PN}"

# TODO: root bin daemon sys adm disk wheel floppy tape video
ACCT_USER_GROUPS=("${PN}" "wheel")

acct-user_add_deps

pkg_postinst() {
	acct-user_pkg_postinst

	# generate a secure password:
	local pwd="$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-27 || die)"
	echo -e "${pwd}\n${pwd}" | passwd "${PN}"
	ewarn "Temporary password is \"${pwd}\", please change it soon!"
}
