FROM ubuntu AS build

ENV http_proxy http://proxy-chain.intel.com:911
ENV https_proxy http://proxy-chain.intel.com:912
ENV ftp_proxy http://proxy-chain.intel.com:911
ENV socks_proxy http://proxy-us.intel.com:1080
ENV no_proxy intel.com,.intel.com,localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12

RUN apt-get update
RUN apt-get install git -y

ENV KERNEL_VERSION=5d069dbe8aaf2a197142558b6fb2978189ba3454
ENV KERNEL_DIR="linux-$KERNEL_VERSION"

WORKDIR /root
RUN mkdir "$KERNEL_DIR"
RUN ls -l
WORKDIR "$KERNEL_DIR"

RUN git init
RUN git remote add origin https://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git
RUN git fetch origin --depth=10 $KERNEL_VERSION
RUN git checkout $KERNEL_VERSION
RUN git log --oneline

WORKDIR /root
RUN ls -l
ENV KERNEL_TARBALL "${KERNEL_DIR}.tar.xz"
RUN apt-get install xz-utils
RUN tar cfJ "$KERNEL_TARBALL" "$KERNEL_DIR"
RUN sha256sum -b $KERNEL_TARBALL > "sha256sums.asc"
RUN ls -l
RUN git clone https://github.com/kata-containers/kata-containers.git
WORKDIR /root/kata-containers/tools/packaging/kernel/
RUN mv /root/$KERNEL_TARBALL .
RUN mv /root/sha256sums.asc .
RUN apt-get install make -y
RUN apt-get install gcc -y
RUN apt-get install flex -y
RUN apt-get install bison -y
RUN apt-get install libelf-dev -y
RUN apt-get install bc -y
RUN ./build-kernel.sh -v "$KERNEL_VERSION" -f setup
RUN ./build-kernel.sh -v "$KERNEL_VERSION" build
ENV DESTDIR "/kata-destdir"
ENV PREFIX="/opt/kata"
RUN ./build-kernel.sh -v "$KERNEL_VERSION" install
RUN ls -l /kata-destdir/opt/kata/share/kata-containers/*
WORKDIR /kata-destdir
RUN tar -czvf /root/kata-kernel.tar.gz *
FROM alpine
COPY --from=build /root/kata-kernel.tar.gz /root/kata-kernel.tar.gz
RUN mkdir -p /katahost/opt/kata/
ENTRYPOINT ["sh"]
