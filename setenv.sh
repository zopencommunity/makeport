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

	export PATH=$PWD/bin:$PATH
	export LIBOBJDIR=

	# See makebuild.sh for valid values of MAKE_xxx variables
	export MAKE_VRM="make-4.3" 
	export MAKE_OS390_TGT_AMODE="64" # 31|64
	export MAKE_OS390_TGT_LINK="dynamic" # static|dynamic
	export MAKE_OS390_TGT_CODEPAGE="ascii" # ebcdic|ascii

	export MAKE_ROOT="${PWD}"
	if [ -z "$GIT_ROOT" ]; then
		export GIT_ROOT=/rsusr/ported/bin
	fi  

	export MAKE_ENV="${MAKE_ROOT}/${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"

	export PATH="${MAKE_ENV}:${MAKE_ROOT}/bin:$PATH"

	echo "Environment set up for ${MAKE_ENV}"
fi
