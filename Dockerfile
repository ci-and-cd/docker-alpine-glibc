
FROM alpine:3.7

MAINTAINER haolun

COPY data/glibc.tar /data/glibc.tar

RUN tar xf /data/glibc.tar -C /
