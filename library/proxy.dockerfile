FROM nginx:1.21.6
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG buildno

RUN apt-get update && apt-get install -y vim dnsutils net-tools iputils-ping tcpdump curl wget zip unzip

ADD ./proxy/bashrc /root/.bashrc
ADD ./bashrc/bash_aliases.sh /root/.bash_aliases
