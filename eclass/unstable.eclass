case "${EAPI}" in
	"8") ;;
	*) die "${ECLASS}: EAPI ${EAPI} unsupported." ;;
esac

# Trying to deducing the USE_EXPAND, and store to UNSTABLE and MNSTABLE.
# TODO: Documents like everyone.

if [[ -z "${_UNSTABLE_ECLASS}" ]]; then
_UNSTABLE_ECLASS=1

# Exported, for indentifing the really MNSTABLE, we can't do much dynamic in
# the ebuild system.
USESTABLE=()

# Setup the IUSE with all possible machines and users. In portage, the IUSE
# should be a "fixed" string for sourcing, therefore it's value must be
# calculated before everything else.
#
# TODO: Avoid this kind of hard-code dependency?
# Machine: {repo}/pygoscelis-papua/portage/files/{machine}
# User: {repo}/acct-user/{user}
_UNSTABLE_REPO="${BASH_SOURCE[0]%/*}"
_UNSTABLE_REPO="${_UNSTABLE_REPO%/*}"

for _UNSTABLE_F in "${_UNSTABLE_REPO}/pygoscelis-papua/portage/files/"*; do
	if [[ -f "${_UNSTABLE_F}/use" ]]; then
		_UNSTABLE_M="${_UNSTABLE_F##*/}"
		IUSE+=" mnstable_${_UNSTABLE_M}"

		if [[ "${_UNSTABLE_M}" == "${MNSTABLE}" ]]; then
			# For the initial setup, the (default) $MNSTABLE is from environment.
			for _UNSTABLE_U in $(< "${_UNSTABLE_F}/use"); do
				IUSE+=" +${_UNSTABLE_U}"
				USESTABLE+=("${_UNSTABLE_U}")
			done
		else
			# For follwing setup, the $MNSTABLE is came from the package.use.
			for _UNSTABLE_U in $(< "${_UNSTABLE_F}/use"); do
				IUSE+=" ${_UNSTABLE_U}"
			done
		fi
	fi
done

for _UNSTABLE_U in "${_UNSTABLE_REPO}/acct-user/"*; do
	IUSE+=" unstable_${_UNSTABLE_U##*/}"
done

# Cleaning up something we won't let others to see:
unset _UNSTABLE_F _UNSTABLE_M _UNSTABLE_P _UNSTABLE_U _UNSTABLE_REPO
UNSTABLE=()
MNSTABLE=()

# TODO: The use flag seems only set after emerge sourced the ebuild, sadly.
# At now, you should call this function when you need either the MNSTABLE or
# UNSTABLE variable :(
unstable_mnstable() {
	if [[ ${#UNSTABLE[@]} -ne 0 ]]; then
		return
	fi

	for u in ${IUSE}; do
		if [[ "${u}" == "unstable_"* ]]; then
			UNSTABLE+=("${u#unstable_}")
		elif [[ "${u}" == "mnstable_"* ]]; then
			MNSTABLE+=("${u#mnstable_}")
		fi
	done

	if [[ ${#UNSTABLE[@]} -eq 0 ]]; then
		die "Missing UNSTABLE(s) for user!"
	elif [[ ${#MNSTABLE[@]} -ne 1 ]]; then
		die "Evil MNSTABLE for machine!"
	fi
}

fi
