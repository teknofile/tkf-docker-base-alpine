ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="teknofile"

ARG S6_OVERLAY_VERSION
ARG TARGETPLATFORM

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

RUN if [ "${TARGETPLATFORM}" == "linux/arm64" ] ; then \
      curl -o /tmp/s6-installer -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64-installer ; \
  elif [ "${TARGETPLATFORM}" == "linux/arm/v7" ] ; then \
      curl -o /tmp/s6-installer -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf-installer ; \
  else \
      curl -o /tmp/s6-installer -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64-installer ; \
  fi && \
  chmod +x /tmp/s6-installer && /tmp/s6-installer /


COPY patch/ /tmp/patch

RUN echo "**** Installing build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
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