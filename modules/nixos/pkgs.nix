{ pkgs, cfg, ... }:

let
  edk2Patches = {
    enable = cfg.patch.edk2.enable;
    amd = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/EDK2/amd-edk2-stable202502.patch";
      hash = "sha256-3Fm0Fp5rWgD1hGxbJ2yYQJm1lJh+QrwH9NM7HMpiofo=";
    };
    intel = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/EDK2/intel-edk2-stable202502.patch";
      hash = "sha256-3Fm0Fp5rWgD1hGxbJ2yYQJm1lJh+QrwH9NM7HMpiofo=";
    };
  };

  qemuPatches = {
    enable = cfg.patch.qemu.enable;
    amd = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/QEMU/qemu-9.2.0-amd.patch";
      hash = "sha256-3Fm0Fp5rWgD1hGxbJ2yYQJm1lJh+QrwH9NM7HMpiofo=";
    };
    intel = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/QEMU/qemu-9.2.0-intel.patch";
      hash = "sha256-3Fm0Fp5rWgD1hGxbJ2yYQJm1lJh+QrwH9NM7HMpiofo=";
    };
    libnfs6 = pkgs.fetchpatch {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/QEMU/qemu-9.2.0-libnfs6.patch";
      hash = "sha256-HjZbgwWf7oOyvhJ4WKFQ996e9+3nVAjTPSzJfyTdF+4=";
    };
    cpu = builtins.writeFile ./cpu.patch ''
      diff --git a/hw/i386/pc_q35.c b/hw/i386/pc_q35.c
      index 01c56bf55e..c913432cdc 100644
      --- a/hw/i386/pc_q35.c
      +++ b/hw/i386/pc_q35.c
      @@ -339,7 +339,7 @@ static void pc_q35_machine_options(MachineClass *m)
          pcmc->default_cpu_version = 1;
      
      -   m->family = "pc_x570";
      +   m->family = "${options.qemu.processor.family}";
      -   m->desc = "AMD Ryzen 7 7700X 8-Core Processor";
      +   m->desc = "${options.qemu.processor.name}";
          m->units_per_default_bus = 1;
          m->default_machine_opts = "firmware=bios-256k.bin";
          m->default_display = "std";

    '';
  };
in {
  OVMF = if edk2Patches.enable then
    pkgs.OVMF.overrideAttrs (old: {
      patches = old.patches ++ [
        edk2Patches[cfg.system.processorVendor]
      ];
    })
  else
    pkgs.OVMF;

  qemu = if qemuPatches.enable then
    pkgs.qemu.overrideAttrs (old: {
      patches = old.patches ++ [
        qemuPatches[cfg.system.processorVendor]
        qemuPatches.libnfs6
        qemuPatches.cpu
      ];
    })
  else
    pkgs.qemu;
}