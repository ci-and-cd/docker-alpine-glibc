# docker-alpine-glibc

Alpine glibc for multi-stage docker image build.

Dockerfile [ci-and-cd/docker-alpine-glibc on Github](https://github.com/ci-and-cd/docker-alpine-glibc)

[cirepo/glibc on Docker Hub](https://hub.docker.com/r/cirepo/glibc/)


The main caveat to note is that it does use musl libc instead of glibc and friends,
so certain software might run into issues depending on the depth of their libc requirements.
However, most software doesn't have an issue with this,
so this variant is usually a very safe choice.


## Use this image as a “stage” in multi-stage builds

```dockerfile

FROM alpine:3.8
COPY --from=cirepo/glibc:2.23-r3-alpine-3.8-archive /data/root /

```
