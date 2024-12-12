case "${EAPI}" in
	"8") ;;
	*) die "${ECLASS}: EAPI ${EAPI} unsupported." ;;
esac

# Trying to deducing the USE_EXPAND, and store to UNSTABLE and MNSTABLE.
# TODO: Documents like everyone.
#
# This will add a (r)depend to UNSTABLE users as well.
# The pygoscelis-papua/portage will enforce the USE and USE_EXPAND flags.

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
	if [[ ! -f "${_UNSTABLE_F}/use" ]]; then
		continue
	fi

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
done

for _UNSTABLE_F in "${_UNSTABLE_REPO}/acct-user/"*; do
	_UNSTABLE_U="${_UNSTABLE_F##*/}"
	IUSE+=" unstable_${_UNSTABLE_U}"
	RDEPEND+=" unstable_${_UNSTABLE_U}? ( acct-user/${_UNSTABLE_U} )"
done

# Cleaning up something we don't want others to see:
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

# Directory format: files/{use}/{filter}/...
# Before calling the function, make sure `unstable_mnstable` is called before.
use_directory() {
	if [[ ${#UNSTABLE[@]} -eq 0 ]]; then
		die 'Please call $(unstable_mnstable) first!'
	fi

	for comp in "${FILESDIR}/"*; do
		local name="$(basename "${comp}")"
		case "${name}" in
		"unstable"|"${MNSTABLE[0]}")
			# defaults to use
		;;
		*)
			use "${name}" || continue
		;;
		esac

		for filter in "${@}"; do
			if [[ ! -e "${comp}/${filter}" ]]; then
				continue
			fi

			echo "${comp}/${filter}"
		done
	done
}

# No need to prepare anything.
rm_if_diff() {
	local target="$1"

	if ! diff -q "${target}" "${D}${target}"; then
		ewarn "Replacing conflict: ${target}"
		rm -f "${target}"
	fi
}

# Home manager functions, like https://devmanual.gentoo.org/function-reference/install-functions/
# It combines with `insinto` and `doins`, for convenience.
# TODO: suppress QA warnings, maybe $QA_FLAGS_IGNORED?
homeinto() {
	if [[ ${#UNSTABLE[@]} -eq 0 ]]; then
		die 'Please call $(unstable_mnstable) first!'
	fi

	local target="${1}"
	local op="${2}"
	shift 2

	for usr in "${UNSTABLE[@]}"; do
		local home="$(eval echo "~${usr}" || die)"
		diropts "-o${usr}" "-g${usr}" "-m755"
		dodir "${home}/${target}"

		insopts "-o${usr}" "-g${usr}" "-m644"
		insinto "${home}/${target}"
		HOME="${home}" "${op}" "${@}"
	done
}

fi
