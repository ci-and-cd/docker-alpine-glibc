
FROM cirepo/nix:2.2.1-alpine-3.9


USER root


ARG IMAGE_ARG_ALPINE_MIRROR
ARG IMAGE_ARG_FILESERVER

ARG IMAGE_ARG_GCCLIBS_VERSION
ARG IMAGE_ARG_GLIBC_VERSION
ARG IMAGE_ARG_ZLIB1_VERSION


COPY --chown=root:root docker /data


RUN set -ex \
    && echo ===== Install tools ===== \
    && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/v3.9/main" > /etc/apk/repositories \
    && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/v3.9/community" >> /etc/apk/repositories \
    && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk add --update binutils libstdc++ \
    && rm -rf /tmp/* /var/cache/apk/*

# https://www.archlinux.org/packages/core/x86_64/gcc-libs
# http://archlinux.thaller.ws/core/os/x86_64/gcc-libs-8.2.1+20181127-1-x86_64.pkg.tar.xz

# https://www.archlinux.org/packages/core/x86_64/zlib
# http://archlinux.thaller.ws/core/os/x86_64/zlib-1:1.2.11-3-x86_64.pkg.tar.xz

RUN set -ex \
    && echo ===== Install glibc ===== \
    && if [[ ! -f /data/glibc-${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}.apk ]]; then \
           ${ARIA2C_DOWNLOAD} -d /data -o "glibc-${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}.apk" \
           "${IMAGE_ARG_FILESERVER:-https://github.com}/sgerrand/alpine-pkg-glibc/releases/download/${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}/glibc-${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}.apk"; \
       fi \
    && apk add --allow-untrusted /data/glibc-${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}.apk \
    && if [[ -n "${IMAGE_ARG_GCCLIBS_VERSION}" ]] && [[ "${IMAGE_ARG_GCCLIBS_VERSION}" != "NA" ]]; then \
           echo ===== Install archlinux gcc-libs  =====; \
           echo "http://archlinux.thaller.ws/core/os/x86_64/gcc-libs-${IMAGE_ARG_GCCLIBS_VERSION:-8.2.1+20181127-1}-x86_64.pkg.tar.xz"; \
           if [ ! -f /data/gcc-libs-${IMAGE_ARG_GCCLIBS_VERSION:-8.2.1+20181127-1}-x86_64.pkg.tar.xz ]; then \
               ${ARIA2C_DOWNLOAD} -d /data -o gcc-libs-${IMAGE_ARG_GCCLIBS_VERSION:-8.2.1+20181127-1}-x86_64.pkg.tar.xz \
               "${IMAGE_ARG_FILESERVER:-http://mirrors.aggregate.org/archlinux}/core/os/x86_64/gcc-libs-${IMAGE_ARG_GCCLIBS_VERSION:-8.2.1+20181127-1}-x86_64.pkg.tar.xz"; \
           fi; \
           mkdir /data/gcc; \
           tar -xf /data/gcc-libs-${IMAGE_ARG_GCCLIBS_VERSION:-8.2.1+20181127-1}-x86_64.pkg.tar.xz -C /data/gcc; \
           mv /data/gcc/usr/lib/libgcc* /data/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib; \
           strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so*; \
       fi \
    && if [[ -n "${IMAGE_ARG_ZLIB1_VERSION}" ]] && [[ "${IMAGE_ARG_ZLIB1_VERSION}" != "NA" ]]; then \
           echo ===== Install archlinux zlib  =====; \
           echo "http://archlinux.thaller.ws/core/os/x86_64/zlib-1:${IMAGE_ARG_ZLIB1_VERSION:-1.2.11-3}-x86_64.pkg.tar.xz"; \
           if [[ ! -f /data/zlib-1:${IMAGE_ARG_ZLIB1_VERSION:-1.2.11-3}-x86_64.pkg.tar.xz ]]; then \
               ${ARIA2C_DOWNLOAD} -d /data -o zlib-1:${IMAGE_ARG_ZLIB1_VERSION:-1.2.11-3}-x86_64.pkg.tar.xz \
               "${IMAGE_ARG_FILESERVER:-http://archlinux.thaller.ws}/core/os/x86_64/zlib-1:${IMAGE_ARG_ZLIB1_VERSION:-1.2.11-3}-x86_64.pkg.tar.xz"; \
           fi; \
           mkdir /data/zlib; \
           tar -xf /data/zlib-1:${IMAGE_ARG_ZLIB1_VERSION:-1.2.11-3}-x86_64.pkg.tar.xz -C /data/zlib; \
           mv /data/zlib/usr/lib/* /usr/glibc-compat/lib; \
       fi \
    && rm -rf /data/* /etc/apk/* /tmp/* /var/cache/apk/*
#    && apk del binutils; \
#    && rm -rf /lib/apk/db

USER alpine
