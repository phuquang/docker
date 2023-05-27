FROM nginx:1.23
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG LIB_DIR=./proxy
ARG BASH_DIR=./bash

RUN apt-get update && apt-get install -y vim curl wget zip unzip

ADD "$LIB_DIR/bashrc" /root/.bashrc
ADD "$BASH_DIR/bash_aliases" /root/.bash_aliases

## cleanup
RUN apt-get clean ; rm -rf /var/lib/apt/lists/* ; rm -rf /tmp/*
