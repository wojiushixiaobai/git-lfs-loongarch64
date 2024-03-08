FROM golang:1.21-buster as builder
ARG TARGETARCH

ARG BUILD_DEPENDENCIES="           \
        ca-certificates            \
        devscripts                 \
        git                        \
        software-properties-common"

RUN set -ex \
    && apt-get update \
    && apt-get install -y ${BUILD_DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

ARG VERSION=v3.5.1

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/git-lfs/git-lfs /opt/git-lfs

WORKDIR /opt/git-lfs

RUN set -ex \
    && apt-get update \
    && mk-build-deps -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" -i debian/control

RUN set -ex \
    && go mod vendor \
    && dpkg-buildpackage -us -uc -I \
    && cd .. \
    && rm -rf git-lfs

FROM debian:buster-slim

WORKDIR /opt/git-lfs

COPY --from=builder /opt /opt/git-lfs/dist

VOLUME /dist

CMD cp -rf dist/* /dist/
