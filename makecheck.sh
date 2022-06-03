#!/bin/sh
if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
  (cd "${PORT_ROOT}/make-4.3/tests" && perl ./run_make_tests.pl -srcdir ../ -make ../make 2>&1)
else
  echo "No support yet to build PORT_TYPE=${PORT_TYPE}." >&2
  exit 4
fi
