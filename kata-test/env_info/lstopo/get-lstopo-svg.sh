#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
img_file="${1}"
img_file=$(realpath "${img_file}")

cd ${script_dir}
sudo docker build -t kata-lstopo --build-arg HTTP_PROXY="${http_proxy}" .

sudo docker run -ti --rm --privileged kata-lstopo lstopo --output-format svg > "${img_file}"
