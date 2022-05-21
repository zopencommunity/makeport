#!/bin/sh
#
# Set up environment variables for general build tool to operate
#
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
	return 0
fi

export PORT_ROOT="${PWD}"
export PORT_TYPE="TARBALL"

export PORT_TARBALL_URL="https://ftp.gnu.org/gnu/make/make-4.3.tar.gz"
export PORT_TARBALL_DEPS="curl gzip make m4 perl"

export PORT_GIT_URL="https://git.savannah.gnu.org/git/make.git"
export PORT_GIT_DEPS="git make m4 perl autoconf automake help2man makeinfo xz"

export PORT_EXTRA_CFLAGS="-D_LARGE_TIME_API -D_OPEN_MSGQ_EXT -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -DPATH_MAX=1024 -D_UNIX03_SOURCE -D_UNIX03_THREADS -D_UNIX03_WITHDRAWN"
export PORT_EXTRA_LDFLAGS=""

if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
	export PORT_BOOTSTRAP=skip
fi
