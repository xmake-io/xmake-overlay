# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xmake

DESCRIPTION="🎁 A glib-like multi-platform c library"
HOMEPAGE="https://github.com/tboox/tbox"
SRC_URI="https://github.com/tboox/tbox/archive/refs/tags/v${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
#BDEPEND="dev-build/xmake"

#src_prepare() {
#	default;
#}

IUSE="debug"

LDFLAGS+=" -Wl,-z,noexecstack"

src_configure() {
	export XMAKE_PROJECT_KIND="shared";
	#export XMAKE_EXTRA_CONFIG_FLAGS=( "--hash=y" "--demo=n" "--small=n" );
	export XMAKE_EXTRA_CONFIG_FLAGS=( "--demo=n" "--small=y" "--charset=y" "--hash=y" "--force-utf8=y" );

	xmake_configure;
}

# FIXME THE GENERATED SHARED LIBRARY CONTAINS BAD CODE.

# * QA Notice: The following files contain writable and executable sections
# *  Files with such sections will not work properly (or at all!) on some
# *  architectures/operating systems.  A bug should be filed at
# *  https://bugs.gentoo.org/ to make sure the issue is fixed.
# *  For more information, see:
# * 
# *    https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart
# * 
# *  Please include the following list of files in your report:
# *  Note: Bugs should be filed for the respective maintainers
# *  of the package in question and not hardened@gentoo.org.
# * RWX --- --- usr/lib64/libtbox.so.1.7.9


# FIXME Should handle either /usr/lib or /usr/lib64 depending on the system arch
src_install() {
	xmake_install;

	#rm -rf "/${ED}/usr/bin";

	#if [[ "/usr/$(get_libdir)" != "/usr/lib" ]];
	#then
	#	mkdir "${ED}/usr/$(get_libdir)";
	#	mv --verbose "${ED}/usr/lib"/* "${ED}/usr/$(get_libdir)";
	#fi

	#chmod 644 "${ED}/usr/$(get_libdir)/libtbox.so.1.7.9";
	#chmod 644 "${ED}/usr/$(get_libdir)/libtbox.so.1";
	#chmod 644 "${ED}/usr/$(get_libdir)/libtbox.so";
}
