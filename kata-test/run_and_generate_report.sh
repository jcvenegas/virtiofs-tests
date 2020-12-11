#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_dir=$(dirname "$(readlink -f "$0")")

"${script_dir}/build-qemu-and-run-fio-test.sh"
"${script_dir}/results_to_csv.sh"
"${script_dir}/report/gen-html-fio-report.sh" "${script_dir}/results"
