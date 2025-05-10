{ pkgs, cfg, lib, ... }:

let
  kernelPatches = {
    enable = cfg.patch.kernel.enable;
    amd = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/Kernel/linux-6.13-svm.patch";
      hash = "sha256-zz18xerutulLGzlHhnu26WCY8rVQXApyeoDtCjbejIk=";
    };
    intel = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/Kernel/zen-kernel-6.14-latest-vmx.mypatch";
      hash = "sha256-zz18xerutulLGzlHhnu26WCY8rVQXApyeoDtCjbejIk=";
    };
  };
  lookingGlass = cfg.hybrid.lookingGlass;
  pciPassthrough = cfg.system.pciIds != [];
in with lib; {
  boot.kernelPackages = mkIf kernelPatches.enable (pkgs.linuxPackages_6_13);
  boot.kernelPatches = mkIf kernelPatches.enable [
    {
      name = "hypervisor-phantom-amd";
      patch = kernelPatches[cfg.system.processorVendor];
    }
  ];
  boot.kernelParams = [
    "iommu=pt"
    lib.mkIf cfg.system.processorVendor == "intel" "intel_iommu=on"
    lib.mkIf lookingGlass.enable "kvmfr.static_size_mb=${lookingGlass.size}"
  ];
  boot.initrd.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    lib.mkIf pciPassthrough "vfio_pci"
    lib.mkIf lookingGlass.enable "kvmfr"
  ];
  boot.kernel.sysctl = lib.mkIf cfg.hybrid.hugePages.enable {
    "vm.nr_hugepages" = 0;
    "vm.nr_overcommit_hugepages" = cfg.hybrid.hugePages.number;
  };

  boot.extraModprobeConfig = lib.mkIf pciPassthrough ''
    options vfio-pci ids=${concatStringsSep "," cfg.system.pciIds};
  '';

}