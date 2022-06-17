#!/bin/sh
# make should have 10 failures or less
#
chk="$2_check.log"

set -x
failures=$(grep ".* Tests in .* Categories Failed" ${chk} | cut -f1 -d' ')
if [ ${failures} -gt 10 ]; then
  exit 1
else
  exit 0
fi
