build:
	docker build -t kata-kernel .

install: build
	docker run -ti --rm -v /opt/kata:/katahost/opt/kata kata-kernel -c 'tar xvf /root/kata-kernel.tar.gz -C /katahost/'
