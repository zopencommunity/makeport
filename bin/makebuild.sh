#!/bin/sh 
#set -x
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#  - network connectivity to pull git source from org
#
if [ $# -ne 4 ]; then
	if [ "${MAKE_VRM}x" = "x" ] ; then
		echo "Either specify all target build options on the command-line or with environment variables\n" >&2

		echo "Syntax: $0 [<vrm>]\n" >&2
		echo "  where:\n" >&2
		echo "  <vrm> is one of maint-5.34 or blead\n" >&2
		exit 16
	fi
else
	export MAKE_VRM="$1"
fi

if [ "${MY_ROOT}" = '' ]; then
	echo "Need to set MY_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${GIT_ROOT}" = '' ]; then
	echo "Need to set GIT_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${MAKE_VRM}" = '' ]; then
	echo "Need to set MAKE_VRM - source setenv.sh" >&2
	exit 16
fi

whence xlclang >/dev/null
if [ $? -gt 0 ]; then
	echo "xlclang required to build Make. " >&2
	exit 16
fi

MIN_GIT_VERSION="2.14.4"
gitversion="$(git --version)"
print "$(print "min version $MIN_GIT_VERSION\n$gitversion")" | sort -Vk3 2>/dev/null | tail -1 | grep -q git

if [ $? -gt 0 ]; then
    echo "Git version >= 2.14.4 is required";
    exit 16
fi

MAKEPORT_ROOT="${PWD}"

set -x
makebld="${MAKE_VRM}-build"
MAKEBLD_ROOT="${MAKEPORT_ROOT}/${makebld}";

# if empty, remove directory
if [ -d "${MAKEBLD_ROOT}" ] && [ -z "$(ls -A ${MAKEBLD_ROOT})" ]; then
  rmdir ${MAKEBLD_ROOT}
fi

if ! [ -d "${MAKEBLD_ROOT}" ]; then
	mkdir -p "${MAKEBLD_ROOT}"
	echo "Clone Make"
	date
	if [ "${GIT_URL}x" != "x" ] ; then
		(curl -o "${MAKE_VRM}.tar.gz" "${TARBALL_URL}/${MAKE_VRM}.tar.gz" && chtag -r "${MAKE_VRM}.tar.gz" && gunzip -dc "${MAKE_VRM}.tar.gz" | pax -r && mv "${MAKE_VRM}" "${MAKEBLD_ROOT}" )
	else
		git clone "${GIT_URL}" "${MAKEBLD_ROOT}"
	fi
	if [ $? -gt 0 ]; then
		echo "Unable to clone Make directory tree" >&2
		exit 16
	fi
fi

managepatches.sh 
rc=$?
if [ $rc -gt 0 ]; then
	exit $rc
fi

cd "${makebld}"
#
# Setup the configuration 
#
rm -f $PWD/alloca.o
touch $PWD/alloca.o
echo "Configure Make"
date
export PATH=$PWD:$PATH
export LIBPATH=$PWD:$LIBPATH
export CC=xlclang
export CFLAGS="-Wc,gonum,lp64 -qascii -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -D_AE_BIMODAL=1 -D_XOPEN_SOURCE_EXTENDED -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED  -qnose -qfloat=ieee -I${MAKEBLD_ROOT}/lib,${MAKEBLD_ROOT}/src,/usr/include"
export LDFLAGS='-Wl,LP64'
nohup sh ./configure >/tmp/config.${makebld}.out 2>&1
rc=$?
if [ $rc -gt 0 ]; then
	echo "Configure of Make tree failed." >&2
	exit $rc
fi

nohup sh build.sh >/tmp/build.${makebld}.out 2>&1 
rc=$?
if [ $rc -gt 0 ]; then
	echo "Build of Make tree failed." >&2
	exit $rc
fi
