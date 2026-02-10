# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: xmake.eclass
# @MAINTAINER:
# benoit.dufour@mail.com
# @AUTHOR:
# benoit.dufour@mail.com
# @SUPPORTED_EAPIS: 8
# @BLURB: automatize the installation of xmake based projects
# @DESCRIPTION: 
# The cmake eclass makes creating ebuilds for cmake-based packages much easier.
# It automatizes the process of configuring, building and installing xmake projects.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ! ${_XMAKE_ECLASS} ]]; then
_XMAKE_ECLASS=1

inherit flag-o-matic

# FIXME Should I add dependencies to cmake or make as well???
BDEPEND="dev-build/xmake"

# @ECLASS_VARIABLE: XMAKE_SRC_INSTALL_DIR
# @DESCRIPTION:
# This variable allows setting the root path where the binaries will be installed.
# Defaults to '${ED}/usr/'
: "${XMAKE_SRC_INSTALL_DIR:="${ED}/usr/"}"

# @ECLASS_VARIABLE: XMAKE_SRC_INSTALL_DIR
# @DESCRIPTION:
# This variable allows setting extra config flags to pass to xmake config.
# Defaults to '${ED}/usr/'
: "${XMAKE_EXTRA_CONFIG_FLAGS:=()}"


# @ECLASS_VARIABLE: XMAKE_PROJECT_KIND
# @DESCRIPTION:
# This variable allows setting overriding XMAKE build kind.
# Set this variable to either executable, shared or static.
# Some settings might not be compatible with all projects,
# so stick with default if you don't know what to use.
# Defaults to '${ED}/usr/'
: "${XMAKE_PROJECT_KIND:="default"}"

xmake_prepare() {
	# FIXME At least with tbox --small=n, package.fetch_only doesn't work.
	# TODO Set build.distcc.remote_only to the right value for better integration with portage distcc
	# TODO Set build.optimization.lto to the right value for better integration with portage lto settings
	# TODO Set build.ccache to the right value for better integration with portage ccache settings.

	local xmakerc="$(
		printf 'option("strip", {default = true, description = "Strip debug symbols"})\n' &&
		printf '\n' &&
		printf 'if not has_config("strip") then\n' &&
		printf '    set_strip("none")\n' &&
		printf 'end\n' &&
		printf '\n' &&
		printf "set_prefixdir(\"/\", {libdir = \"$(get_libdir)\"})\n" &&
		printf '\n' &&
		printf "set_policy(\"package.fetch_only\")" &&
		printf '\n' &&
		printf "set_policy(\"build.progress_style\", \"multirow\")"
	)";
	
	echo "${xmakerc}" > "${HOME}/portage_xmakerc.lua" || die;
}

xmake_src_prepare() {
	default_src_prepare;

	xmake_prepare;
}

xmake_configure() {
	#export XMAKE_LOGFILE="${TEMP}/build.log";
	export XMAKE_RCFILES="${HOME}/portage_xmakerc.lua";

	local _ldflags="";
	local _raw_ldflags=( $(raw-ldflags) );
	#for flag in "${_raw_ldflags[@]}";
	#do
	#	if [[ "${flag}" != '--as-needed' ]]; then
	#		_ldflags+="-Wl,${flag} ";
	#	fi
	#done

	#die "_ldflags=${_ldflags}";

	local TARGET_KIND_FLAG;
	local LINKER_FLAGS;

    if [[ "${XMAKE_PROJECT_KIND}" == 'default' ]]; then
		die "You turd should know what you're trying to build.";
    elif [[ "${XMAKE_PROJECT_KIND}" == 'shared' ]]; then
		TARGET_KIND_FLAG='--kind=shared';
        LINKER_FLAGS="--shflags=${LDFLAGS}";
	elif [[ "${XMAKE_PROJECT_KIND}" == 'static' ]]; then
		TARGET_KIND_FLAG='--kind=static';
		LINKER_FLAGS="--arflags=${LDFLAGS}";
	elif [[ "${XMAKE_PROJECT_KIND}" == 'executable' ]]; then
		TARGET_KIND_FLAG='--kind=binary';
		LINKER_FLAGS="--ldflags=${LDFLAGS}";
	else
		die "What the fuck are you trying to do here?";
    fi

	einfo "XMFLAGS: '${XMAKE_EXTRA_CONFIG_FLAGS[@]}'";
	einfo "RCFILES: '${XMAKE_RCFILES}'";
	einfo " CFLAGS: '${CFLAGS}'";
	einfo "LDFLAGS: '${LDFLAGS}'";
	einfo "LINKER_FLAGS: ${LINKER_FLAGS[@]}";

	## loop through above array (quotes are important if your elements may contain spaces)
	#for opt in "${XMAKE_EXTRA_CONFIG_FLAGS[@]}";
	#do
	#	local opt_name="$(echo "${opt}" | cut -d'-' -f3- | cut -d'=' -f1)";
	#	local opt_value="$(echo "${opt}" | cut -d'-' -f3- | cut -d'=' -f2)";
	#
	#done

	# Mandatory for forcing the full reconfiguration of the project.
	#xmake clean --all;

	local build_mode="release";

	if use debug ; then
		build_mode="debug";
	fi

	local LINKER_FLAGS;

	if [ -z "${XMAKE_EXTRA_CONFIG_FLAGS}" ]; then
		einfo "No extra config flags detected.";
		xmake config \
		--plat='linux' \
		--cflags="${CFLAGS}" \
		"${TARGET_KIND_FLAG}" \
		"${LINKER_FLAGS}" \
		--strip='n' \
		--mode=${build_mode} \
		--policies='package.fetch_only' \
		--diagnosis || die;
	else
		einfo "Configuring the xmake project with the detected extra config flags";
		xmake config \
		--plat='linux' \
		${XMAKE_EXTRA_CONFIG_FLAGS[@]} \
		--cflags="${CFLAGS}" \
		"${TARGET_KIND_FLAG}" \
		"${LINKER_FLAGS}" \
		--strip='n' \
		--mode=${build_mode} \
		--policies='package.fetch_only' \
		--diagnosis || die;
	fi
}

xmake_src_configure() {
	xmake_configure;
}

xmake_compile() {
	#export XMAKE_LOGFILE="${TEMP}/build.log";
    export XMAKE_RCFILES="${HOME}/portage_xmakerc.lua";

	xmake build --diagnosis || die;
}

xmake_src_compile() {
	xmake_compile;
}

xmake_install() {
	#export XMAKE_LOGFILE="${TEMP}/build.log";
    export XMAKE_RCFILES="${HOME}/portage_xmakerc.lua";

	# FIXME Will it work with gentoo prefixes as well???
	if [[ "$(id --user)" == '0' ]]; then
		export XMAKE_ROOT=y;
	fi

	if [ -z "${XMAKE_EXTRA_CONFIG_FLAGS}" ]; then
		xmake install || die;
	else
		xmake install --installdir="${XMAKE_SRC_INSTALL_DIR}" || die;
	fi
}

xmake_src_install() {
	xmake_install;
}

fi

# TODO Add src_test as well???
#EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install
