# SPDX-License-Identifier: GPL-3.0-or-later
#
# macos-kvm Docker image — run macOS in a container via QEMU/KVM.
# Derived from sickcodes/Docker-OSX and kholia/OSX-KVM.
#
# Requirements on the host:
#   /dev/kvm must be accessible
#   X11 socket or VNC client for display
#
# Build:
#   docker build -t macos-kvm .
#   docker build -t macos-kvm --build-arg VERSION=sonoma --build-arg RAM=8 .
#
# Run (GUI via X11):
#   docker run --device /dev/kvm --device /dev/snd \
#     -v /tmp/.X11-unix:/tmp/.X11-unix \
#     -e DISPLAY=$DISPLAY \
#     macos-kvm
#
# Run (headless, SSH on 10022):
#   docker run --device /dev/kvm -p 10022:10022 -e HEADLESS=1 macos-kvm

FROM archlinux:base-devel

ARG VERSION=sonoma
ARG RAM=4
ARG CORES=2
ARG SIZE=128G
ARG MAC_ADDRESS=52:54:00:c9:18:27

ENV VERSION=${VERSION} \
    RAM=${RAM} \
    CORES=${CORES} \
    SIZE=${SIZE} \
    MAC_ADDRESS=${MAC_ADDRESS} \
    HEADLESS=0

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN pacman -Syu --noconfirm \
    qemu-full \
    python3 \
    dmg2img \
    wget \
    git \
    xterm \
    && pacman -Scc --noconfirm

WORKDIR /macos-kvm

# Copy repo contents
COPY . .

# Download firmware
RUN make firmware

# Create disk image
RUN qemu-img create -f qcow2 mac_hdd.qcow2 ${SIZE}

# Fetch macOS recovery image
RUN python3 fetch/fetch-macos.py --version ${VERSION} --outdir fetch/ \
    && bash fetch/convert-image.sh fetch/BaseSystem.dmg fetch/BaseSystem.img \
    || true   # image may already exist in a pre-built layer

EXPOSE 10022 5900

CMD ["bash", "docker/entrypoint.sh"]
