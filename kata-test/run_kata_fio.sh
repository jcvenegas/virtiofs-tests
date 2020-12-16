#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_dir=$(dirname "$(readlink -f "$0")")
results_dir="${script_dir}/results"

set_base_virtiofs_config(){
	# Running kata-qemu-virtiofs
	# Defaults for virtiofs
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"none"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 1024
}


fn_name(){
	  echo "${FUNCNAME[1]}"
}

kata_env(){
	local runtime=${1}
	local suffix=${2}
	local config_path
	local kata_env_bk
	local kata_config_bk
	local qemu_applied_patches
	kata_env_bk="$(get_results_dir "${suffix}")/kata-env.toml"
	kata_config_bk="$(get_results_dir "${suffix}")/kata-config.toml"
	qemu_applied_patches="$(get_results_dir "${suffix}")/qemu-patches"

	/opt/kata/bin/${runtime} kata-env > "${kata_env_bk}"
	config_path="$(/opt/kata/bin/${runtime} kata-env --json | jq .Runtime.Config.Path -r)"
	cp "${config_path}" "${kata_config_bk}"
	cp /opt/virtiofs/share/applied_patches "${qemu_applied_patches}"
}

get_results_dir(){
	local test_name
	local test_result_dir
	test_name="${1}"
	test_result_dir="${results_dir}/${test_name}"
	mkdir -p "${test_result_dir}"
	echo "${test_result_dir}"
}

collect_qemu_virtiofs_cmd(){
	local rdir
	local test_name
	test_name="${1}"

	rdir=$(get_results_dir "${test_name}")
	sudo docker rm -f kata-info || true
	sudo docker run --name kata-info --runtime "${runtime}" -dti busybox sh
	ps aux| grep virtiofsd > "${rdir}/virtiofsd_cmd"
	ps aux| grep qemu > "${rdir}/qemu_cmd"
	sudo docker rm -f kata-info
}

collect_docker_info(){
	local rdir
	local test_name
	test_name="${1}"

	rdir=$(get_results_dir "${test_name}")
	sudo docker info > "${rdir}/docker_info"
}

run_workload(){
	local runtime
	local test_name
	local test_result_dir
	local iotop_pid

	runtime="${1}"
	test_name="${2}"

	test_result_file="$(get_results_dir "${test_name}")/test-out.txt"
	iotop_csv="$(get_results_dir "${test_name}")/iotop.csv"

	echo "case: ${runtime} ${test_name}"
	collect_qemu_virtiofs_cmd "$test_name"
	collect_docker_info "$test_name"

	export CONTAINER_RUNTIME="${runtime}"
	"${script_dir}/iotop_collect.sh" "${iotop_csv}" &
	iotop_pid=$!
	(
	cd "${script_dir}/.."
	sudo -E ${script_dir}/../run-fio-test.sh --size 100M --direct 0  --loops 1 "${test_name}" . fio-jobs/*.job | tee "${test_result_file}"
	)
	sudo kill -9 "${iotop_pid}"
}

virtiofs_pool_0_auto_dax(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=0","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"auto"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 1024
	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_0_auto(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=0","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"auto"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 0

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_0_none(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=0","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"none"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 0

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_0_none_dax(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=0","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"none"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 1024

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_tread_pool_64(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=64"]'

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

#### 64 threads
virtiofs_pool_64_auto_dax(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=64","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"auto"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 1024
	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_64_auto(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=64","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"auto"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 0

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_64_none(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=64","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"none"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 0

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}

virtiofs_pool_64_none_dax(){
	local runtime="kata-qemu-virtiofs"
	local suffix="$(fn_name)"

	set_base_virtiofs_config
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_extra_args '["--thread-pool-size=64","-o","no_posix_lock","-o","xattr"]'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache '"none"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_cache_size 1024

	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}


9pfs_mmap_msize_200000(){
	local runtime="kata-qemu"
	local suffix="$(fn_name)"

	sudo sed -i 's,#msize,msize,g' /opt/kata/share/defaults/kata-containers/configuration-qemu.toml || true
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu.toml hypervisor.qemu msize_9p "200000"
	kata_env "${runtime}" "${suffix}"
	run_workload "${runtime}" "${suffix}"
}
runc_container(){
	local runtime="runc"
	local suffix="$(fn_name)"

	run_workload "${runtime}" "${suffix}"
}

mkdir -p "${results_dir}"
${script_dir}/env_info/lstopo/get-lstopo-svg.sh hwtopo.svg
9pfs_mmap_msize_200000

virtiofs_pool_0_auto
virtiofs_pool_0_auto_dax

virtiofs_pool_0_none
virtiofs_pool_0_none_dax

virtiofs_pool_64_auto
virtiofs_pool_64_auto_dax

virtiofs_pool_64_none
virtiofs_pool_64_none_dax

runc_container
