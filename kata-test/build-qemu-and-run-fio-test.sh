#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_dir=$(dirname "$(readlink -f "$0")")

build_qemu(){
	(
	cd "${script_dir}/qemu-virtiofs"
	sudo rm -rf "/opt/virtiofs/"
	make clean
	make
	sudo make install

	# Configure kata to make both 9pfs and virtiofs use the same qemu binaries

	#kata-virtiofs
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu path '"/opt/virtiofs/bin/qemu-virtiofs-system-x86_64"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu virtio_fs_daemon '"/opt/virtiofs/bin/virtiofsd"'

	#kata-qemu
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu.toml hypervisor.qemu path '"/opt/virtiofs/bin/qemu-virtiofs-system-x86_64"'
	)
	cp /opt/virtiofs/share/applied_patches qemu-log-applied-patches
}

qemu_rh_dyn(){
	export STATIC_BUILD="false"
	build_qemu
	${script_dir}/run_kata_fio.sh
}

qemu_rh_static(){
	export STATIC_BUILD="true"
	build_qemu
	${script_dir}/run_kata_fio.sh
}

default_qemu(){
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu-virtiofs.toml hypervisor.qemu path '"/opt/kata/bin/qemu-system-x86_64"'
	sudo crudini --set --existing /opt/kata/share/defaults/kata-containers/configuration-qemu.toml hypervisor.qemu path '"/opt/kata/bin/qemu-system-x86_64"'
	${script_dir}/run_kata_fio.sh | tee log-qemu-default
}

build_and_install_kernel(){
	(
	cd ${script_dir}/kernel/
	sudo make
	sudo make install
	)
}

build_and_install_kernel
qemu_rh_static
#qemu_rh_dyn
#default_qemu
