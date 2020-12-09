FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y fio htop && \
	apt-get remove -y unattended-upgrades


# Work in the root of the container
WORKDIR /
ADD . /fio-jobs/

CMD ["sh", "-c", "sleep infinity"]
