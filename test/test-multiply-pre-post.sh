#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before1.sh
create_succeeding_test ${WORKDIR}/before2.sh
create_succeeding_test ${WORKDIR}/after1.sh
create_succeeding_test ${WORKDIR}/after2.sh
create_succeeding_test ${WORKDIR}/before-all1.sh
create_succeeding_test ${WORKDIR}/before-all2.sh
create_succeeding_test ${WORKDIR}/after-all1.sh
create_succeeding_test ${WORKDIR}/after-all2.sh

OUT=$(tt-runner ${WORKDIR} --multiply-pre-post)

[[ ${OUT} == "1..26
ok 1 before-all1.sh
ok 2 before-all2.sh
ok 3 before-all1.sh
ok 4 before-all2.sh
ok 5 before1.sh
ok 6 before2.sh
ok 7 test1.sh
ok 8 after2.sh
ok 9 after1.sh
ok 10 before1.sh
ok 11 before2.sh
ok 12 test2.sh
ok 13 after2.sh
ok 14 after1.sh
ok 15 before1.sh
ok 16 before2.sh
ok 17 before1.sh
ok 18 before2.sh
ok 19 after2.sh
ok 20 after1.sh
ok 21 after2.sh
ok 22 after1.sh
ok 23 after-all2.sh
ok 24 after-all1.sh
ok 25 after-all2.sh
ok 26 after-all1.sh" ]]