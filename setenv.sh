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

	if [ "${GIT_ROOT}x" = "x" ]; then
	        export GIT_ROOT="${HOME}/zot/boot/git"
	fi
	if [ "${CURL_ROOT}x" = "x" ]; then
	        export CURL_ROOT="${HOME}/zot/boot/curl"
	fi
	if [ "${PERL_ROOT}x" = "x" ]; then
	        export PERL_ROOT="${HOME}/zot/boot/perl"
	fi
	if [ "${M4_ROOT}x" = "x" ]; then
		export M4_ROOT="${HOME}/zot/prod/m4"
        fi
        if [ "${MAKE_INSTALL_PREFIX}x" = "x" ]; then
 		export MAKE_INSTALL_PREFIX="${HOME}/zot/prod/make"
        fi

 	export MY_ROOT="${PWD}"
        export PATH="${GIT_ROOT}/bin:${M4_ROOT}/bin:${CURL_ROOT}/bin:${PERL_ROOT}/bin:${PATH}"
        export PATH="${MY_ROOT}/bin:${PATH}"
	export PATH="${MAKE_ROOT}/bin:$PATH"

	export GIT_SSL_CAINFO="${MY_ROOT}/git-savannah-gnu-org-chain.pem"
	echo "Environment set up for ${MAKE_VRM}"
fi
