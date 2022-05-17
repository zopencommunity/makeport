#!/bin/sh
#
# Manage patches
# To create or refresh patch:
#   -perform a git diff of the affected files and redirect to a patch file
#
#set -x
if [ $# -ne 0 ]; then
	echo "Syntax: managepatches" >&2
	echo "  refreshes patch files" >&2
	exit 8
fi

# mydir="$(dirname $0)"

if [ "${MY_ROOT}" = '' ]; then
	echo "Need to set MY_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${MAKE_VRM}" = '' ]; then
	echo "Need to set MAKE_VRM - source setenv.sh" >&2
        exit 16
fi

makepatch="${MAKE_VRM}"
makecode="${MAKE_VRM}"

CODE_ROOT="${MY_ROOT}/${makecode}-build"
PATCH_ROOT="${MY_ROOT}/${makepatch}-patches"
patches=`cd ${PATCH_ROOT} && find . -name "*.patch"`
results=`(cd ${CODE_ROOT} && git status --porcelain --untracked-files=no 2>&1)`
if [ "${results}" != '' ]; then
  echo "Existing Changes are active in ${CODE_ROOT}. To re-apply patches, perform a git reset on ${CODE_ROOT} prior to running managepatches again."
  exit 0	
fi 

failedcount=0
for patch in $patches; do
	p="${PATCH_ROOT}/${patch}"

	patchsize=`wc -c "${p}" | awk '{ print $1 }'` 
	if [ $patchsize -eq 0 ]; then
		echo "Warning: patch file ${p} is empty - nothing to be done" >&2 
	else 
		echo "Applying ${p}"
		out=`(cd ${CODE_ROOT} && git apply "${p}" 2>&1)`
		if [ $? -gt 0 ]; then
			echo "Patch of make tree failed (${p})." >&2
			echo "${out}" >&2
			failedcount=$((failedcount+1))
		fi
	fi
done

exit $failedcount
