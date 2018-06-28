# docker-alpine-glibc

Alpine glibc for multi-stage docker image build.

Dockerfile [ci-and-cd/docker-alpine-glibc on Github](https://github.com/ci-and-cd/docker-alpine-glibc)

[cirepo/alpine-glibc on Docker Hub](https://hub.docker.com/r/cirepo/alpine-glibc/)


The main caveat to note is that it does use musl libc instead of glibc and friends,
so certain software might run into issues depending on the depth of their libc requirements.
However, most software doesn't have an issue with this,
so this variant is usually a very safe choice.


## Use this image as a “stage” in multi-stage builds

```dockerfile
FROM alpine:3.7
COPY --from=cirepo/alpine-glibc:3.7_2.23-r3 /data/layer.tar /data/layer.tar
RUN tar xf /data/layer.tar -C /
```
