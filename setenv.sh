#!/bin/sh
#set -x
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(DUMP)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

	# See makebuild.sh for valid values of MAKE_xxx variables
	export MAKE_VRM="make-4.3" 
# Note to build make you need to either use a tarball that is pre-configured
# or clone the code from git.
#
# If you use the pre-configured make source tarball, you need a 'bootstrap' make
# and you need curl to pull down the tarball
#
# If you clone the code from git, you need to already have the Autotools installed
# on your system
#
 	gitsource=false
	unset GIT_URL
	unset TARBALL_URL
	if $gitsource ; then
		export MAKE_VRM="make-4.3"
		export GIT_URL="https://git.savannah.gnu.org/git/make.git"
	else
            	export TARBALL_URL="http://ftp.gnu.org/gnu/make"
		export MAKE_VRM="make-4.3"
	fi

	if [ "${GIT_ROOT}x" = "x" ]; then
	        export GIT_ROOT="${HOME}/zot/boot/git"
	fi
	if [ "${CURL_ROOT}x" = "x" ]; then
	        export CURL_ROOT="${HOME}/zot/boot/curl"
	fi
	if [ "${PERL_ROOT}x" = "x" ]; then
	        export PERL_ROOT="${HOME}/zot/prod/perl"
	fi
	if [ "${M4_ROOT}x" = "x" ]; then
		export M4_ROOT="${HOME}/zot/prod/m4"
        fi
        if [ "${MAKE_INSTALL_PREFIX}x" = "x" ]; then
 		export MAKE_INSTALL_PREFIX="${HOME}/zot/prod/make"
        fi
	if [ "${GZIP_ROOT}x" = "x" ]; then
    		export GZIP_ROOT="${HOME}/zot/boot/gzip"
    	fi

 	export MY_ROOT="${PWD}"
        export PATH="${GIT_ROOT}/bin:${M4_ROOT}/bin:${CURL_ROOT}/bin:${PERL_ROOT}/bin:${GZIP_ROOT}/bin:${PATH}"
        export PATH="${MY_ROOT}/bin:${PATH}"

        for libperl in $(find "${PERL_ROOT}" -name "libperl.so"); do
        	lib=$(dirname "${libperl}")
		export LIBPATH="${lib}:${LIBPATH}"
		break
        done
	export PERL5LIB_ROOT=$( cd ${PERL_ROOT}/lib/perl5/5*; echo $PWD )
        export PERL5LIB="${PERL5LIB_ROOT}:${PERL5LIB_ROOT}/os390"

	export GIT_SSL_CAINFO="${MY_ROOT}/git-savannah-gnu-org-chain.pem"
	echo "Environment set up for ${MAKE_VRM}"
fi
