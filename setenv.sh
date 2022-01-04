#!/bin/sh
#set -x
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(MSG)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

	if [ "$HOME" != '' ] && [ -d $HOME/bin ]; then
		export PATH=$HOME/bin:/usr/local/bin:/bin:/usr/sbin
	else
		export PATH=/usr/local/bin:/bin:/usr/sbin
	fi  
	export LIBPATH=/lib:/usr/lib
	export LIBOBJDIR=

	# See makebuild.sh for valid values of MAKE_xxx variables
	export MAKE_VRM="make-4.3" 
	export MAKE_OS390_TGT_AMODE="64" # 31|64
	export MAKE_OS390_TGT_LINK="dynamic" # static|dynamic
	export MAKE_OS390_TGT_CODEPAGE="ascii" # ebcdic|ascii

	export MAKE_ROOT="${PWD}"
	export GIT_ROOT=/rsusr/ported/bin

	export PATH="${MAKE_ROOT}/bin:$PATH"

	export MAKE_ENV="${MAKE_ROOT}/${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"

	echo "Environment set up for ${MAKE_ENV}"
fi
