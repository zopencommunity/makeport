#!/bin/sh
#
# Manage patches
# To create a new patch:
#   -cd to patches directory, create any sub-directories if required, and create an empty patch file by touch'ing it
# To refresh patches:
#   -run managepatches
#   -This will look at all the patch files, update them, and then patch the source files
#
#set -x
if [ $# -ne 0 ]; then
	echo "Syntax: managepatches" >&2
	echo "  refreshes patch files" >&2
	exit 8
fi

mydir="$(dirname $0)"

if [ "${MAKE_ROOT}" = '' ]; then
	echo "Need to set MAKE_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${MAKE_VRM}" = '' ]; then
	echo "Need to set MAKE_VRM - source setenv.sh" >&2
        exit 16
fi

makepatch="${MAKE_VRM}"
makecode="${MAKE_VRM}.${MAKE_OS390_TGT_AMODE}.${MAKE_OS390_TGT_LINK}.${MAKE_OS390_TGT_CODEPAGE}"

CODE_ROOT="${MAKE_ROOT}/${makecode}"
PATCH_ROOT="${MAKE_ROOT}/${makepatch}/patches"
commonpatches=`cd ${PATCH_ROOT} && find . -name "*.patch"`
specificpatches=`cd ${PATCH_ROOT} && find . -name "*.patch${MAKE_OS390_TGT_CODEPAGE}"`
patches="$commonpatches $specificpatches"
for patch in $patches; do
	rp="${patch%*.patch*}"
	o="${CODE_ROOT}/${rp}.orig"
	f="${CODE_ROOT}/${rp}"
	p="${PATCH_ROOT}/${patch}"

	if [ -f "${o}" ]; then
		# Original file exists. Regenerate patch, then replace file with original version 
		diff -C 2 -f "${o}" "${f}" | tail +3 >"${p}"
		cp "${o}" "${f}"
	else
		# Original file does not exist yet. Create original file
		cp "${f}" "${o}"
	fi

	out=`patch -c "${f}" <"${p}" 2>&1`
	if [ $? -gt 0 ]; then
		echo "Patch of make tree failed (${f})." >&2
		echo "${out}" >&2
		exit 16
	fi
done

exit 0	
