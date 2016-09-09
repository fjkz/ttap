#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before.sh
create_succeeding_test ${WORKDIR}/after.sh

OUT=$(tt-runner ${WORKDIR} --tap)

[[ ${OUT} == "1..6
ok 1 before.sh.1
ok 2 test1.sh
ok 3 after.sh.1
ok 4 before.sh.2
ok 5 test2.sh
ok 6 after.sh.2" ]]
