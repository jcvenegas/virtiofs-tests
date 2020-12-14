FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

ENV http_proxy http://proxy-chain.intel.com:911
ENV https_proxy http://proxy-chain.intel.com:912
ENV ftp_proxy http://proxy-chain.intel.com:911
ENV socks_proxy http://proxy-us.intel.com:1080
ENV no_proxy intel.com,.intel.com,localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12

RUN apt-get update && \
	apt-get install -y fio htop && \
	apt-get remove -y unattended-upgrades


# Work in the root of the container
WORKDIR /
ADD . /fio-jobs/

CMD ["sh", "-c", "sleep infinity"]
