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

if [ "${MY_ROOT}" = '' ]; then
	echo "Need to set MY_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${MAKE_VRM}" = '' ]; then
	echo "Need to set MAKE_VRM - source setenv.sh" >&2
        exit 16
fi

makepatch="${MAKE_VRM}-patches"
makecode="${MAKE_VRM}-build"

CODE_ROOT="${MY_ROOT}/${makecode}"
PATCH_ROOT="${MY_ROOT}/${makepatch}"
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
 	patchsize=`wc -c "${p}" | awk '{ print $1 }'` 
 	if [ $patchsize -eq 0 ]; then
 		echo "Warning: patch file ${f} is empty - nothing to be done" >&2 
 	else 
		# patch does not respect tags. convert the generated EBCDIC file to ASCII
 		out=`patch -c "${f}" <"${p}" 2>&1`
 		if [ $? -gt 0 ]; then
 			echo "Patch of make tree failed (${f})." >&2
 			echo "${out}" >&2
 			exit 16
 		fi
		out=`iconv -f "IBM-1047" -t "ISO8859-1" <"${f}" >"${f}.ascii"`
 		if [ $? -gt 0 ]; then
 			echo "iconv of patched file in make tree failed (${f})." >&2
 			echo "${out}" >&2
 			exit 16
 		fi
		chtag -t -c "ISO8859-1" "${f}.ascii"
		rm "${f}"
		mv "${f}.ascii" "${f}"
	fi
done

exit 0	
