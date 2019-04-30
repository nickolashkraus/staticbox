FROM alpine as base

# add compilation packages
RUN apk add \
      build-base \
      linux-headers

# add utilities
RUN apk add \
      curl \
      make

FROM base as busybox

ARG BUSYBOX_VERSION=1.30.1

RUN curl -LO https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 \
      && tar -xjf busybox-${BUSYBOX_VERSION}.tar.bz2 \
      && mkdir /busybox \
      && mv busybox-${BUSYBOX_VERSION}/* /busybox \
      && rm -rf busybox-${BUSYBOX_VERSION}*

WORKDIR /busybox

COPY .config/.defconfig .config

RUN make && make install

FROM alpine

COPY --from=busybox /busybox/busybox /staticbox/bin/busybox

RUN for f in /bin/*; do \
      if [[ -h $f  ]]; then \
        ln -sf /staticbox/bin/busybox /staticbox/bin/$(basename $f); \
      fi \
    done

ENV PATH=/staticbox/bin:$PATH
