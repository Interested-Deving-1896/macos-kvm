# SPDX-License-Identifier: GPL-3.0-or-later
# macos-kvm — top-level Makefile

SHELL := /usr/bin/env bash
REPO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

FIRMWARE_DIR := $(REPO_ROOT)firmware
DISK_IMAGE   := $(REPO_ROOT)mac_hdd.qcow2
DISK_SIZE    ?= 128G
VERSION      ?= sonoma

.PHONY: all firmware disk fetch boot headless docker clean help

all: help

help:
	@echo "macos-kvm targets:"
	@echo "  make firmware        Download OVMF firmware blobs"
	@echo "  make disk            Create a blank macOS HDD image (DISK_SIZE=$(DISK_SIZE))"
	@echo "  make fetch           Download macOS recovery image (VERSION=$(VERSION))"
	@echo "  make boot            Start macOS VM (GUI)"
	@echo "  make headless        Start macOS VM (VNC on :5900)"
	@echo "  make docker          Build Docker image"
	@echo "  make clean           Remove generated files"

firmware:
	@echo "Downloading OVMF firmware ..."
	@mkdir -p $(FIRMWARE_DIR)
	@if ! command -v wget &>/dev/null; then echo "ERROR: wget required"; exit 1; fi
	wget -q -nc -P $(FIRMWARE_DIR) \
	  https://github.com/kholia/OSX-KVM/raw/master/OVMF_CODE_4M.fd \
	  https://github.com/kholia/OSX-KVM/raw/master/OVMF_VARS-1920x1080.fd \
	  https://github.com/kholia/OSX-KVM/raw/master/OVMF_VARS-1024x768.fd
	@echo "Firmware ready in $(FIRMWARE_DIR)"

disk:
	@if [[ -f "$(DISK_IMAGE)" ]]; then \
	  echo "$(DISK_IMAGE) already exists. Delete it first to recreate."; \
	else \
	  echo "Creating $(DISK_IMAGE) ($(DISK_SIZE)) ..."; \
	  qemu-img create -f qcow2 $(DISK_IMAGE) $(DISK_SIZE); \
	  echo "Done."; \
	fi

fetch:
	python3 fetch/fetch-macos.py --version $(VERSION) --outdir fetch/

boot: firmware disk
	bash boot/boot.sh

headless: firmware disk
	HEADLESS=1 bash boot/boot.sh

docker:
	docker build -t macos-kvm -f docker/Dockerfile .

clean:
	rm -f fetch/BaseSystem.img fetch/BaseSystem.dmg fetch/*.chunklist
	@echo "Disk image and firmware preserved. Remove manually if needed."
