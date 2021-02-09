FROM alpine:3.13

LABEL maintainer="teknofile"

ARG OVERLAY_VERSION
ARG OVERLAY_ARCH

RUN apk add --no-cache \
  bash \
  curl \
  tzdata \ 
  xz \
  alpine-keys \
  alpine-baselayout \
  apk-tools \
  busybox \
  libc-utils

# Add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer /tmp/
RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer
RUN /tmp/s6-overlay-${OVERLAY_ARCH}-installer /
RUN rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

COPY patch/ /tmp/patch

# Setup enviornment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

RUN echo "**** Installing build packages ****"
RUN apk add --no-cache --virtual=build-dependencies \
  curl \
  patch \
  tar

RUN echo "**** Installing runtime packages ****"
RUN apk add --no-cache \
  bash \
  ca-certificates \
  coreutils \
  procps \
  shadow \
  tzdata

RUN echo "**** Creatring the abc user and making dirs for our use ****"
RUN groupmod -g 1000 users
RUN useradd -u 911 -U -d /config -s /bin/false abc
RUN usermod -G users abc
RUN mkdir -p /app /config /defaults
RUN mv /usr/bin/with-contenv /usr/bin/with-contenvb
RUN patch -u /etc/s6/init/init-stage2 -i /tmp/patch/etc/s6/init/init-stage2.patch
RUN echo "**** cleanup ****"
RUN apk del --purge build-dependencies
RUN rm -rf /tmp/*

# Add local files
COPY root/ /

ENTRYPOINT [ "/init" ]

