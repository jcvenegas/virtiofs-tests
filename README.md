# virtiofs-tests
A placeholder for virtio-fs tests

# Setup Environment
- Install fio
- Setup target directory where fio file will be setup and I/O will be done
  to these files

# Run Tests
- cd virtiofs-tests
- Assumeing virtio-fs is mounted at /mnt/virtio-fs/ and config name is
  virtiofs-always-dax. 
- ./run-fio-tests.sh virtiofs-always-dax /mnt/virtio-fs/ fio-jobs/*.job > fio-results-virtiofs-always-dax.txt
## Run with a kata containers and docker
```
export CONTAINER_RUNTIME=kata-qemu
or
export CONTAINER_RUNTIME=kata-qemu-virtiofs
```

# Parse Results
- ./parse-fio-results fio-results-virtiofs-always-dax.txt
## Export results in csv
```
REPORT_FORMAT="csv"
```
