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
	if [ "${MAKE_VRM}" = "" ] || [ "${MAKE_OS390_TGT_AMODE}" = "" ] || [ "{MAKE_OS390_TGT_LINK}" = "" ] || [ "{MAKE_OS390_TGT_CODEPAGE}" = "" ]; then
		echo "Either specify all 4 target build options on the command-line or with environment variables\n" >&2

		echo "Syntax: $0 [<vrm> <amode> <link> <codepage>]\n" >&2
		echo "  where:\n" >&2
		echo "  <vrm> is one of maint-5.34 or blead\n" >&2
		echo "  <amode> is one of 31 or 64\n" >&2
		echo "  <link> is one of static or dynamic\n" >&2
		echo "  <codepage> is one of ascii or ebcdic\n" >&2
		exit 16
	fi
else
	export MAKE_VRM="$1"
	export MAKE_OS390_TGT_AMODE="$2"
	export MAKE_OS390_TGT_LINK="$3"
	export MAKE_OS390_TGT_CODEPAGE="$4"
fi

if [ "${MAKE_ROOT}" = '' ]; then
	echo "Need to set MAKE_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${MAKE_VRM}" = '' ]; then
	echo "Need to set MAKE_VRM - source setenv.sh" >&2
	exit 16
fi

whence c99 >/dev/null
if [ $? -gt 0 ]; then
	echo "c99 required to build Make. " >&2
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

makebld="${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"
MAKEBLD_ROOT="${MAKEPORT_ROOT}/${makebld}";

# if empty, remove directory
if [ -z "$(ls -A ${MAKEBLD_ROOT})" ]; then
  rmdir ${MAKEBLD_ROOT}
fi

if ! [ -d "${MAKEBLD_ROOT}" ]; then
	mkdir -p "${MAKEBLD_ROOT}"
	echo "Clone Make"
	date
	(cd "${MAKEBLD_ROOT}" && git clone https://git.savannah.gnu.org/git/make.git)

	if [ $? -gt 0 ]; then
		echo "Unable to clone Make directory tree" >&2
		exit 16
	fi

	chtag -R -h -t -cISO8859-1 "${MAKEBLD_ROOT}"

	if [ $? -gt 0 ]; then
		echo "Unable to tag Make directory tree as ASCII" >&2
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
nohup sh ./configure CC=c99 CFLAGS="-qlanglvl=extc1x -Wc,gonum,lp64 -qascii -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -D_AE_BIMODAL=1 -D_XOPEN_SOURCE_EXTENDED -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED  -qnose -qfloat=ieee -I${MAKEBLD_ROOT}/lib,${MAKEBLD_ROOT}/src,/usr/include" LDFLAGS='-Wl,LP64' >/tmp/config.${makebld}.out 2>&1
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
