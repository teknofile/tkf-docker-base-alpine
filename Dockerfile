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
RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
  /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
  rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

COPY patch/ /tmp/patch


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

RUN echo "**** Creatring the abc user and making dirs for our use ****" && \
  groupmod -g 1000 users && \
  useradd -u 911 -U -d /config -s /bin/false abc && \
  usermod -G users abc && \
  mkdir -p /app /config /defaults && \
  mv /usr/bin/with-contenv /usr/bin/with-contenvb && \
  patch -u /etc/s6/init/init-stage2 -i /tmp/patch/etc/s6/init/init-stage2.patch && \
  echo "**** cleanup ****" && \
  apk del --purge build-dependencies && \
  rm -rf /tmp/*

# Add local files
COPY root/ /

ENTRYPOINT [ "/init" ]
