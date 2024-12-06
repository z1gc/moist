EAPI="8"

inherit acct-user

ACCT_USER_ID="1000"
ACCT_USER_ENFORCE_ID="yes"
ACCT_USER_SHELL="/bin/bash"
ACCT_USER_HOME="/home/${PN}"

# TODO: root bin daemon sys adm disk wheel floppy tape video
ACCT_USER_GROUPS=("${PN}" "wheel")

acct-user_add_deps
