# Hypervisor Phantom: Nix

This is a nix port of [Hypervisor-Phantom](https://github.com/Scrut1ny/Hypervisor-Phantom).

> [!WARNING]
> This is **NOT** working currently. More work needs to be done.

## Features

- Support for both AMD and Intel
- PCI passthrough
- Looking Glass
- Patches
  - Kernel
  - EDK2 (OVMF, firmware)
  - QEMU
- XML
  - Spoofing most identifiers
  - evdev (input) passthrough
  - Various optimisations
    - CPU pinning
    - Huge pages
