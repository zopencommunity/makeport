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

MAKEPORT_ROOT="${PWD}"

makebld="${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"

if ! [ -d "${MAKEPORT_ROOT}/${makebld}" ]; then
	mkdir -p "${MAKEPORT_ROOT}/${makebld}"
	echo "Clone Make"
	date
#	(cd "${MAKEPORT_ROOT}/${makebld}" && ${GIT_ROOT}/git clone https://git.savannah.gnu.org/git/make.git)
	cp -rpf ${MAKEPORT_ROOT}/make.local/${MAKE_VRM}/* "${MAKEPORT_ROOT}/${makebld}"

	if [ $? -gt 0 ]; then
		echo "Unable to clone Make directory tree" >&2
		exit 16
	fi

	chtag -R -h -t -cISO8859-1 "${MAKEPORT_ROOT}/${makebld}"

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
ConfigOpts='CC=c99'
rm -f $PWD/alloca.o
touch $PWD/alloca.o
echo "Configure Make"
date
export PATH=$PWD:$PATH
export LIBPATH=$PWD:$LIBPATH
nohup sh ./configure ${ConfigOpts} >/tmp/config.${makebld}.out 2>&1
rc=$?
if [ $rc -gt 0 ]; then
	echo "Configure of Make tree failed." >&2
	exit $rc
fi

nohup sh build.sh >/tmp/build.${makebld}.out 2>&1 
rc=$?
if [ $rc -gt 0 ]; then
	echo "Configure of Make tree failed." >&2
	exit $rc
fi
