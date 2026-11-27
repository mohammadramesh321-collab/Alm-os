#!/usr/bin/env bash
set -euo pipefail

# Build on a Debian/Ubuntu x86_64 (amd64) Linux machine, not inside Android Termux.
if [[ "$(dpkg --print-architecture 2>/dev/null || true)" != "amd64" ]]; then
  echo "ERROR: This build script needs an amd64/x86_64 Debian or Ubuntu host."
  echo "Your current environment is not amd64. Android Termux is usually arm64."
  echo "Use an amd64 Linux PC/VM, or a cloud amd64 Linux machine, for the ISO build."
  exit 2
fi
if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo ./build-iso.sh"
  exit 2
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y live-build debootstrap xorriso squashfs-tools

cd "$(dirname "$0")"
lb clean --purge || true
lb config \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer false \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components username=user hostname=aml-os"
lb build

if [[ -f live-image-amd64.hybrid.iso ]]; then
  cp live-image-amd64.hybrid.iso AML-OS-amd64.iso
  echo "Build complete: $(pwd)/AML-OS-amd64.iso"
else
  echo "Build command finished, but expected ISO was not found. Check the output above."
  exit 1
fi
