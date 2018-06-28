#!/usr/bin/env bash

set -e

docker version
docker-compose version

WORK_DIR=$(pwd)

if [ -n "${CI_OPT_DOCKER_REGISTRY_PASS}" ] && [ -n "${CI_OPT_DOCKER_REGISTRY_USER}" ]; then
    echo ${CI_OPT_DOCKER_REGISTRY_PASS} | docker login --password-stdin -u="${CI_OPT_DOCKER_REGISTRY_USER}" docker.io
fi

IMAGE_TAG=3.7_${IMAGE_ARG_GLIBC_VERSION:-2.23-r3}

BUILDER_IMAGE_NAME=tmp/builder
if [[ "$(docker images -q ${BUILDER_IMAGE_NAME}:${IMAGE_TAG} 2> /dev/null)" == "" ]]; then
    docker-compose build builder
fi

docker save ${BUILDER_IMAGE_NAME}:${IMAGE_TAG} > /tmp/builder.tar
rm -rf /tmp/builder && mkdir -p /tmp/builder && tar -xf /tmp/builder.tar -C /tmp/builder
for layer in /tmp/builder/*/layer.tar; do
    echo ${layer}
    mkdir -p $(dirname ${layer})/layer && tar -xf ${layer} -C $(dirname ${layer})/layer
done

#LAST_DIFF_ID=$(docker image inspect -f '{{json .RootFS.Layers}}' ${BUILDER_IMAGE_NAME}:${IMAGE_TAG} | jq -r 'last' | awk -F':' '{print $2}')
LAST_LAYER=$(find -d /tmp/builder -name "glibc-compat" | grep "/usr/glibc-compat" | awk -F'/' '{print $4}')
echo LAST_LAYER ${LAST_LAYER}

#tar cf ${WORK_DIR}/data/glibc.tar -C /tmp/builder/${LAST_LAYER}/layer .
# ignore empty directories
#(cd /tmp/builder/${LAST_LAYER}/layer && find . -type f -print0 | sed -z 's#^.##' | sed -z 's#^/##' | xargs -0 tar --no-recursion -cvf ${WORK_DIR}/data/glibc.tar)
cp -f /tmp/builder/${LAST_LAYER}/layer.tar data/glibc.tar
#mkdir -p data/glibc && tar xf data/glibc.tar -C data/glibc

IMAGE_NAME=${IMAGE_PREFIX:-cirepo}/alpine-glibc
if [ "${TRAVIS_BRANCH}" != "master" ]; then IMAGE_TAG=${IMAGE_TAG}-SNAPSHOT; fi

docker-compose build alpine-glibc
docker-compose push alpine-glibc
