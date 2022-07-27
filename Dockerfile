ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="teknofile"

ARG S6_OVERLAY_VERSION
ARG TARGETPLATFORM

RUN apk add --no-cache \
  bash \
  curl \
  wget \
  tzdata \ 
  xz \
  alpine-keys \
  alpine-baselayout \
  apk-tools \
  busybox \
  libc-utils

RUN if [ "${TARGETPLATFORM}" == "linux/arm64" ] ; then \
    curl -o /tmp/s6.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz ; \
  elif [ "${TARGETPLATFORM}" == "linux/arm/v7" ] ; then \
    curl -o /tmp/s6.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf.tar.xz ; \
  else \
    curl -o /tmp/s6.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz ; \
  fi

#ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN curl -o /tmp/s6-overlay-noarch.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz

RUN ls -alh /tmp/s6*xz
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6.tar.xz

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
  echo "**** cleanup ****" && \
  apk del --purge build-dependencies && \
  rm -rf /tmp/*

# Fix some perms issues (potentially?)
RUN echo "**** Fixing perms ****" && \
	chmod +x /etc/cont-init.d/*

# Add local files
COPY root/ /

ENTRYPOINT [ "/init" ]
