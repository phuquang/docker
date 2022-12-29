FROM python:3.7-stretch
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

RUN apt-get -y update \
    && apt-get -y install build-essential libssl-dev git zlib1g-dev

RUN git clone https://github.com/giltene/wrk2.git wrk2 \
    && cd wrk2 \
    && make

RUN mv wrk2/wrk /usr/local/bin/wrk

RUN rm -rf wrk2

## cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

HEALTHCHECK CMD exit 0
