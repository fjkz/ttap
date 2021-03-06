#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_failing_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/test3.sh
create_succeeding_test ${WORKDIR}/test4.sh

OUT=$(ttap ${WORKDIR} --stop-on-failure --format tap) || :

[[ ${OUT} == \
"ok 1 test1.sh
not ok 2 test2.sh
ok 3 # SKIP test3.sh
ok 4 # SKIP test4.sh
1..4" ]]
