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


if [ -z "${MAKE_OS390_TGT_LOG_DIR}" ]; then
  MAKE_OS390_TGT_LOG_DIR=/tmp
fi

MIN_GIT_VERSION="2.14.4"
gitversion="$(git --version)"
print "$(print "min version $MIN_GIT_VERSION\n$gitversion")" | sort -Vk3 2>/dev/null | tail -1 | grep -q git

if [ $? -gt 0 ]; then
    echo "Git version >= 2.14.4 is required";
    exit 16
fi

if ! out=$( perl --version ) ; then
	echo "Perl is required for testing make" >&2
	exit 16
fi

MAKEPORT_ROOT="${PWD}"

echo "Logs will be stored to ${MAKE_OS390_TGT_LOG_DIR}"

if [ ! -z "${MAKE_INSTALL_DIR}" ]; then
  install_dir=${MAKE_INSTALL_DIR}
else
  install_dir="${HOME}/local/make"
fi

mkdir -p $install_dir
if [ $? -gt 0 ]; then
  echo "Install directory $install_dir cannot be created"
  exit 16
fi
ConfigOpts="--prefix=$install_dir"

echo "Extra configure options: $ConfigOpts"

makebld="${MAKE_VRM}-build"
MAKEBLD_ROOT="${MAKEPORT_ROOT}/${makebld}";

# if empty, remove directory
if [ -d "${MAKEBLD_ROOT}" ] && [ -z "$(ls -A ${MAKEBLD_ROOT})" ]; then
  rmdir ${MAKEBLD_ROOT}
fi

if ! [ -d "${MAKEBLD_ROOT}" ]; then
	echo "Clone Make"
	date
	if [ "${TARBALL_URL}x" != "x" ] ; then
		(curl -s -o "${MAKE_VRM}.tar.gz" "${TARBALL_URL}/${MAKE_VRM}.tar.gz" && chtag -r "${MAKE_VRM}.tar.gz" && gunzip -dc "${MAKE_VRM}.tar.gz" | pax -r && mv "${MAKE_VRM}" "${MAKEBLD_ROOT}" )
	else
		git clone "${GIT_URL}" "${MAKEBLD_ROOT}"
	fi
	if [ $? -gt 0 ]; then
		echo "Unable to clone Make directory tree" >&2
		exit 16
	fi
	chtag -R -tc 819 ${MAKEBLD_ROOT}
	chmod 755 "${MAKEBLD_ROOT}/configure"
	(cd "${MAKEBLD_ROOT}" && git init . && git add . && git commit --allow-empty -m "Initialize repository")
fi

managepatches.sh 
rc=$?
if [ $rc -gt 0 ]; then
	exit $rc
fi

cd "${MAKEBLD_ROOT}"
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
export CFLAGS="-D_ALL_SOURCE -qASCII -q64 -D_LARGE_TIME_API -D_OPEN_MSGQ_EXT -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -DPATH_MAX=1024 -D_UNIX03_SOURCE -D_UNIX03_THREADS -D_UNIX03_WITHDRAWN -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED"
export LDFLAGS='-q64'
nohup sh ./configure --prefix="${MAKE_INSTALL_PREFIX}" >${MAKE_OS390_TGT_LOG_DIR}/config.${makebld}.out 2>&1
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
(cd tests && perl  ./run_make_tests.pl -srcdir ../ -make ../make 2>&1) | tee ${MAKE_OS390_TGT_LOG_DIR}/test.${makebld}.txt || true

echo "Make Install"
nohup make install >${MAKE_OS390_TGT_LOG_DIR}/install.${makebld}.out 2>&1
rc=$?
if [ $rc -gt 0 ]; then
  echo "MAKE install of Make tree failed." >&2
  exit $rc
fi
