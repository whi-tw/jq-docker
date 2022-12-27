ARG JQ_TAG=jq-1.6

FROM alpine:3.17.0 as builder

RUN apk --no-cache add --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
        git \
        libtool \
        linux-headers \
        make

FROM builder as build
ARG JQ_TAG
WORKDIR /workspace

RUN git clone https://github.com/stedolan/jq \
    && cd jq  \
    && git checkout ${JQ_TAG} \
    && git submodule update --init \
    && autoreconf -fi \
    && ./configure --with-oniguruma=builtin --disable-maintainer-mode \
    && make -j$(nproc) LDFLAGS=-all-static

FROM alpine:3.17.0

RUN apk --no-cache add \
        bash \
        ca-certificates \
        wget \
        curl

COPY --from=build /workspace/jq/jq /usr/bin/jq
RUN chmod +x /usr/bin/jq

ENV SHELL=/bin/bash

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
