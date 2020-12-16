FROM ubuntu

ARG HTTP_PROXY

ENV http_proxy $HTTP_PROXY

RUN apt-get update
RUN apt-get install hwloc -y
