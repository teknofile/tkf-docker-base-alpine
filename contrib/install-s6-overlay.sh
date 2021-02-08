#!/usr/bin/env bash

set +x

# This script will determin the appropriate architecture
# and then download and install the s6 overlay system
# from the justcontainers github release

OVERLAY_VERSION=$1
OVERLAY_INSTALL_DIR=$2
OVERLAY_ARCH=""

case `uname -m` in
  X86_64)
    echo "You're running on X86_64"
    OVERLAY_ARCH="amd64"
    ;;
  aarch64)
    echo "You're running on aarch64"
    OVERLAY_ARCH="aarch64"
    ;;
  armhf)
    echo "You're running on armhf"
    OVERLAY_ARCH="armhf"
    ;;
esac


if [[ ! -z ${OVERLAY_ARCH} ]]
then
  curl -o /tmp/s6-overlay-installer -fL https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer
  chmod +x /tmp/s6-overlay-installer
  /tmp/s6-overlay-installer ${OVERLAY_INSTALL_DIR}
  rm -f /tmp/s6-overlay-installer
fi
