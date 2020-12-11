#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_dir=$(dirname "$(readlink -f "$0")")
pre_results_file="${script_dir}/results/_results.csv"
results_file="${script_dir}/results/results.csv"

export REPORT_FORMAT="csv"
find ${script_dir}/results/ -name '*.txt' -exec ${script_dir}/../parse-fio-results.sh {}  \; > "${pre_results_file}"
head -1  "${pre_results_file}" > "${results_file}"
header="$(cat ${results_file})"
grep -v "${header}" "${pre_results_file}" >> "${results_file}"
rm "${pre_results_file}"
