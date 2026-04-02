#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Docker container entrypoint for macos-kvm.

set -euo pipefail

# Enable KVM ignore_msrs if possible
if [[ -f /sys/module/kvm/parameters/ignore_msrs ]]; then
    echo 1 > /sys/module/kvm/parameters/ignore_msrs 2>/dev/null || true
fi

BOOT_ARGS=(
    --ram "$(( RAM * 1024 ))"
    --cores "${CORES:-2}"
    --mac "${MAC_ADDRESS:-52:54:00:c9:18:27}"
)

if [[ "${HEADLESS:-0}" == "1" ]]; then
    BOOT_ARGS+=(--headless)
fi

if [[ -f /macos-kvm/fetch/BaseSystem.img ]]; then
    BOOT_ARGS+=(--install /macos-kvm/fetch/BaseSystem.img)
fi

exec bash /macos-kvm/boot/boot.sh "${BOOT_ARGS[@]}"
