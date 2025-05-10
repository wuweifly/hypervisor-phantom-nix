{ cfg, customPkgs, lib, ... }:

let
  makeController = type: index: model: {
    inherit type index model;
  };

  qemu = cfg.qemu;
  processorVendor = cfg.system.processorVendor;

  cpuPinning = lib.mkIf (cpuPinning.pins != []) {
    iothreads.count = qemu.cpuTune.iothreads;
    vcpu.placement = "static";
    vcpu.count = qemu.cpuTune.pins.length;
    cputune.emulatorpin = qemu.cpuTune.cpuset;
    cpu.iothreadpin = { iothread = 1; cpuset = qemu.cpuTune.cpuset; };
    cputune.vcpupin = map (pin: {
      vcpu = pin.vcpu;
      cpuset = pin.cpuset;
    }) qemu.cpuTune.pins;
  } or { };

  cpuFeatures = lib.mkIf (processorVendor == "amd") [
    (makeFeature "require" "svm")
    (makeFeature "require" "topoext")
    (makeFeature "require" "invtsc")
    (makeFeature "disable" "amd-ssbd")
  ] or [
    (makeFeature "disable" "hypervisor")
    (makeFeature "require" "vmx")
  ];

  clockTimers = lib.mkIf (processorVendor == "amd") [
    { name = "rtc"; present = false; tickpolicy = "catchup"; }
    { name = "pit"; tickpolicy = "discard"; }
    { name = "tsc"; present = true; mode = "native"; }
  ] or [
    { name = "rtc"; present = false }
    { name = "pit"; present = false; }
    { name = "tsc"; present = true; tickpolicy = "discard"; mode = "native"; }
  ];

  xml = type = "kvm";
  name = qemu.name;
  uuid = qemu.spoof.uuid;

  memory = qemu.memory;
  currentMemory = qemu.memory;

  inherit cpuPinning;

  sysinfo.type = "smbios";
  sysinfo.bios.entry = with qemu.spoof.sysinfo.bios; [
    (makeNameValue "vendor" vendor)
    (makeNameValue "version" version)
    (makeNameValue "date" date)
  ];
  sysinfo.system.entry = with qemu.spoof.sysinfo.system; [
    (makeNameValue "manufacturer" manufacturer)
    (makeNameValue "product" product)
    (makeNameValue "version" version)
    (makeNameValue "serial" serial)
    (makeNameValue "uuid" qemu.spoof.uuid)
    (makeNameValue "sku" sku)
  ];
  sysinfo.chassis.entry = with qemu.spoof.sysinfo.chassis; [
    (makeNameValue "serial" serial)
  ];

  os = {
    type = "kvm";
    arch = "x86_64";
    machine = "q35";

    bootmenu.enable = true;
    smbios.mode = "host";

    loader = {
      readonly = true;
      type = "pflash";
      path = ${customPkgs.OVMF.fd}/FV/OVMF_CODE.fd;
    };
    nvram = {
      template = ${customPkgs.OVMF.fd}/FV/OVMF_VARS.fd;
      path = /var/lib/libvirt/qemu/nvram/${qemu.name}_VARS.fd;
    };
  };

  features = {
    acpi = { };
    apic = { };
    hyperv = {
      mode = "custom";
      relaxed.state = false;
      vapic.state = false;
      spinlocks.state = false;
      vpindex.state = false;
      runtime.state = false;
      synic.state = false;
      stimer.state = false;
      reset.state = false;
      frequencies.state = false;
      vendor_id = {
        state = true;
        value = lib.mkIf processorVendor == "amd" "AuthenticAMD" or "GenuineIntel";
      };
    };
    kvm.hidden.state = true;
    smm.state = true;
    pmu.state = false;
    ioapic.driver = "kvm";
    msrs.unknown = "fault";
  };

  cpu = {
    mode = "host-passthrough";
    check = "none";
    migratable = false;

    topology = qemu.cpuTune.topology;

    cache.mode = "passthrough";

    feature = [
      (makeFeature "disable" "rdpid")
      (makeFeature "disable" "ssbd")
      (makeFeature "disable" "virt-ssbd")
    ] ++ cpuFeatures;
  };

  clock = {
    offset = "passthrough";

    timer = [
      { name = "hpet"; present = false; }
      { name = "kvmclock"; present = false; }
      { name = "hypervclock"; present = true; }
    ] ++ clockTimers;
  };

  on_poweroff = "destroy";
  on_reboot = "restart";
  on_crash = "destroy";

  pm = {
    suspend-to-mem.enabled = true;
    suspend-to-disk.enabled = true;
  };

  devices = {
    emulator = "${customPkgs.qemu}/bin/qemu-system-x86_64";

    disk = {
      type = "file";
      device = "disk";
      serial = qemu.spoof.diskSerial;

      driver = {
        name = "qemu";
        type = qemu.virtualStorage.type;
        cache = "none";
        io = "native";
        discard = "ignore";
      };

      source.file = qemu.virtualStorage.location;

      backingStore = { };

      target = {
        dev = "sda";
        bus = "sata";
      };

      boot.order = 1;

      address = {
        type = "drive";
        controller = 0;
        bus = 0;
        target = 0;
        unit = 0;
      };
    };

    interface = [
      {
        type = "bridge";
        mac.address = qemu.spoof.mac;
        source.bridge = "br0";
        model.type = "e1000e"; 
        link.state = "up";
        address = {
          type = "pci";
          domain = 0;
          bus = 1;
          slot = 0;
          function = 0;
        };
      }
    ];
    
    input = map (input: {
      type = "evdev";
      source = mkIf input.keyboard {
        dev = input.path;
        grab = "all";
        grabToggle = "ctrl-ctrl";
        repeat = true;
      } or {
        dev = input.path
      }
    }) qemu.evdev;

    tpm = {
      model = "tpm-crb";
      backend = {
        type = "emulator";
        version = "2.0";
      };
    };

    sound = {
      model = "ich9";
      
      codec.type = "micro";
      audio.id = 1;
      address = {
        type = "pci";
        domain = 0;
        bus = 0;
        slot = 27;
        function = 0;
      };
    };

    video.model.type = "none";

    watchdog = {
      model = "itco";
      action = "reset";
    };

    memballoon.model = "none";

    shmem = lib.mkIf cfg.hybrid.lookingGlass.enable {
      name = "looking-glass";

      model.type = "ivshmem-plain";
      size = {
        unit = "M";
        count = cfg.hybrid.lookingGlass.size;
      };
      address = {
        type = "pci";
        domain = 0;
        bus = 16;
        slot = 0;
        function = 0;
      };
    };

    controller = [
      (makeController "usb" 0 "qemu-xhci")
      (makeController "pci" 0 "pcie-root")
      (makeController "pci" 1 "pcie-root-port")
      (makeController "pci" 16 "pcie-to-pci-bridge")
    ];
  };

  qemu-commandline.arg = with qemu.spoof.processor qemu.spoof.ram; [
    (makeValue "-smbios")
    (makeValue "type=0,uefi=true")
    (makeValue "-smbios")
    (makeValue "type=4,sock_pfx=${sockPfx},max-speed=${maxSpeed},current-speed=${currentSpeed}")
    (makeValue "-smbios")
    (makeValue "type=17,loc_pfx=${locPfx},bank=${bank},manufacturer=${manufacturer},serial=${serial},asset=${asset},part=${part},speed=${speed}")
  ];

  qemu-override.device = lib.mkIf qemu.ssdOptimisation {
    alias = "sata0-0-0";
    frontend.property = [
      {
        name = "rotation_rate";
        type = "unsigned";
        value = "1";
      }
      {
        name = "discard_granularity";
        type = "unsigned";
        value = "0";
      }
    ];
  };

  mergedXml = cfg.qemu.extraConfig // xml
{
  inherit mergedXml;
}