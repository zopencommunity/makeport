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

if [ -z "${MAKE_OS390_TGT_LOG_DIR}" ]; then
  MAKE_OS390_TGT_LOG_DIR=/tmp
fi

MAKEPORT_ROOT="${PWD}"

echo "Logs will be stored to ${PERL_OS390_TGT_LOG_DIR}"

if [ ! -z "${MAKE_INSTALL_DIR}" ]; then
  install_dir=${MAKE_INSTALL_DIR}
else
  install_dir="${HOME}/local/make"
fi

if [ -z "${MAKE_OS390_TGT_LOG_DIR}" ]; then
  MAKE_OS390_TGT_LOG_DIR=/tmp
fi
mkdir -p $install_dir
if [ $? -gt 0 ]; then
  echo "Install directory $install_dir cannot be created"
  exit 16
fi
ConfigOpts="--prefix=$install_dir"

echo "Extra configure options: $ConfigOpts"

makebld="${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"
MAKEBLD_ROOT="${MAKEPORT_ROOT}/${makebld}";

if ! [ -d "${MAKEBLD_ROOT}" ]; then
	mkdir -p "${MAKEBLD_ROOT}"
	echo "Clone Make"
	date
	#(cd "${MAKEBLD_ROOT}" && ${GIT_ROOT}/git clone https://git.savannah.gnu.org/git/make.git)
  (cd "${MAKEBLD_ROOT}" && curl -k -o make-4.3.tar.gz https://ftp.gnu.org/gnu/make/make-4.3.tar.gz && chtag -r make-4.3.tar.gz && gunzip -dc make-4.3.tar.gz | pax -r && mv make-4.3 make)
	if [ $? -gt 0 ]; then
		echo "Unable to clone Make directory tree" >&2
		exit 16
	fi
  chtag -R -tc 819 ${MAKEBLD_ROOT}
  chmod 755 "${MAKEBLD_ROOT}make/configure"
  (cd "${MAKEBLD_ROOT}/make" && git init . && git add . && git commit --allow-empty -m "Initialize repository")
fi

managepatches.sh 
rc=$?
if [ $rc -gt 0 ]; then
	exit $rc
fi

cd "${MAKEBLD_ROOT}/make"
#
# Setup the configuration 
#
rm -f $PWD/alloca.o
touch $PWD/alloca.o
echo "Configure Make"
date
set -x
export PATH=$PWD:$PATH
export LIBPATH=$PWD:$LIBPATH
nohup sh ./configure CC=xlclang CFLAGS="-D_ALL_SOURCE -qARCH=9 -qASCII -q64 -D_LARGE_TIME_API -D_OPEN_MSGQ_EXT -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -DPATH_MAX=1024 -D_UNIX03_SOURCE -D_UNIX03_THREADS -D_UNIX03_WITHDRAWN -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED" LDFLAGS='-q64' $ConfigOpts --disable-dependency-tracking > ${MAKE_OS390_TGT_LOG_DIR}/config.${makebld}.out 2>&1 
rc=$?
if [ $rc -gt 0 ]; then
	echo "Configure of Make tree failed." >&2
	exit $rc
fi

echo "Building Make"
nohup sh build.sh >${MAKE_OS390_TGT_LOG_DIR}/build.${makebld}.out 2>&1 
rc=$?
if [ $rc -gt 0 ]; then
	echo "Build of Make tree failed." >&2
	exit $rc
fi

echo "Make Test"
(cd tests && perl  ./run_make_tests.pl -srcdir ../ -make ../make) | tee ${MAKE_OS390_TGT_LOG_DIR}/test.${makebld}.txt || true


echo "Make Install"
nohup make install >${MAKE_OS390_TGT_LOG_DIR}/install.${makebld}.out 2>&1
rc=$?
if [ $rc -gt 0 ]; then
  echo "MAKE install of Make tree failed." >&2
  exit $rc
fi
