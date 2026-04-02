# macos-kvm

Run macOS in QEMU/KVM on Linux. Unified toolkit consolidating
[OSX-KVM](https://github.com/kholia/OSX-KVM),
[macOS-Simple-KVM](https://github.com/foxlet/macOS-Simple-KVM),
[ultimate-macOS-KVM](https://github.com/Coopydood/ultimate-macOS-KVM),
[Docker-OSX](https://github.com/sickcodes/Docker-OSX), and
[osx-optimizer](https://github.com/sickcodes/osx-optimizer).

## Requirements

- Linux host with KVM enabled (`/dev/kvm` accessible)
- `qemu-system-x86_64` ≥ 6.0
- `python3`
- `wget`
- `dmg2img` (for installer conversion)

```bash
# Debian/Ubuntu
sudo apt install qemu-system-x86 python3 wget dmg2img

# Arch
sudo pacman -S qemu-full python wget dmg2img

# Fedora
sudo dnf install qemu-kvm python3 wget dmg2img
```

## Quick start

```bash
# 1. Download OVMF firmware
make firmware

# 2. Create a blank disk image (default 128G)
make disk

# 3. Fetch macOS recovery image (default: sonoma)
make fetch VERSION=sonoma

# 4. Boot into the installer
bash boot/boot.sh --install fetch/BaseSystem.img

# 5. After installation, boot normally
make boot
```

## Supported macOS versions

| Version | `--version` flag |
|---|---|
| macOS Sequoia (15) | `sequoia` |
| macOS Sonoma (14) | `sonoma` |
| macOS Ventura (13) | `ventura` |
| macOS Monterey (12) | `monterey` |
| macOS Big Sur (11) | `bigsur` |
| macOS Catalina (10.15) | `catalina` |
| macOS Mojave (10.14) | `mojave` |
| macOS High Sierra (10.13) | `high-sierra` |

## Boot options

```bash
bash boot/boot.sh --help

# Headless (VNC on :5900)
bash boot/boot.sh --headless

# Custom RAM and CPU
bash boot/boot.sh --ram 8192 --cores 4 --threads 8

# Boot from installer
bash boot/boot.sh --install fetch/BaseSystem.img
```

## Docker

```bash
# Build
docker build -t macos-kvm -f docker/Dockerfile .

# Run (GUI)
docker run --device /dev/kvm --device /dev/snd \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  macos-kvm

# Run (headless, SSH on 10022)
docker run --device /dev/kvm -p 10022:10022 -e HEADLESS=1 macos-kvm

# docker-compose
cd docker && docker-compose up
```

## Guest optimizations

Run inside the macOS guest to improve VM performance:

```bash
# Apply all safe optimizations
bash guest-tools/optimize.sh --all

# Individual options
bash guest-tools/optimize.sh --spotlight-off   # biggest speed gain
bash guest-tools/optimize.sh --perf-mode
bash guest-tools/optimize.sh --no-updates
bash guest-tools/optimize.sh --reduce-motion
```

## libvirt / Virt-Manager

```bash
# Edit CHANGEME paths in boot/libvirt-domain.xml first
sudo virsh define boot/libvirt-domain.xml
sudo virsh start macos-kvm
```

## Directory layout

```
macos-kvm/
├── fetch/              # macOS image download and conversion
│   ├── fetch-macos.py  # Fetches recovery images from Apple CDN
│   └── convert-image.sh
├── boot/               # QEMU launch scripts and OpenCore config
│   ├── boot.sh         # Unified boot script
│   └── libvirt-domain.xml
├── firmware/           # OVMF firmware (downloaded by make firmware)
├── docker/             # Docker/compose integration
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── entrypoint.sh
├── guest-tools/        # Scripts to run inside the macOS guest
│   ├── optimize.sh
│   └── useradd-bulk.sh
└── Makefile
```

## Notes

- `ignore_msrs=1` is required for macOS guests. `boot.sh` sets this automatically.
- The OSK string is publicly known and included here for compatibility; it does not
  circumvent any Apple DRM.
- Running macOS in a VM outside of Apple hardware may violate Apple's SLA.
  This project is intended for development and testing purposes.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) and [CREDITS.md](CREDITS.md).
