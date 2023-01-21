#!/bin/sh
(cd "${ZOPEN_ROOT}/make-4.4.0.90/tests" && perl ./run_make_tests.pl -srcdir ../ -make ../make 2>&1)
