{ lib, helpers, ... }:

let
  mkOption = lib.mkOption;
in with helpers lib.types; {
  name = mkOption {
    type = str;
    default = "nixos";
    description = ''
      The name of the QEMU virtual machine.
    '';
  };

  os = mkOption {
    type = str;
    default = "win/11";
    description = ''
      The operating system to use.
    '';
  };

  memory = mkOption {
    type = countUnitType;
    default = { unit = "G"; count = 8; };
    description = ''
      The amount of memory to use.
    '';
  };

  ssdOptimisation = mkOption {
    type = bool;
    default = false;
    description = ''
      Enable SSD optimisation.
    '';
  };

  cpuTune = mkOption {
    type = submodule {
      options = {
        cpuset = mkOption {
          type = str;
          default = "host";
          description = ''
            The CPU set to use.
          '';
        };
        iothreads = mkOption {
          type = int;
          default = 1;
          description = ''
            The number of I/O threads to use.
          '';
        };
        
        topology = mkOption {
          type = submodule {
            options = {
              cores = mkOption {
                type = int;
                default = 1;
                description = ''
                  The number of cores to use.
                '';
              };
              threads = mkOption {
                type = int;
                default = 2;
                description = ''
                  The number of threads per core.
                '';
              };
              sockets = mkOption {
                type = int;
                default = 1;
                description = ''
                  The number of sockets to use.
                '';
              };
              dies = mkOption {
                type = int;
                default = 1;
                description = ''
                  The number of dies to use.
                '';
              };
            };
          };
        };

        pins = mkOption {
          type = listOf submodule {
            options = {
              vcpu = mkOption {
                type = int;
                default = 0;
                description = ''
                  The virtual CPU to use.
                '';
              };
              cpuset = mkOption {
                type = int;
                default = 0;
                description = ''
                  The CPU set to use.
                '';
              };
            };
          };
          default = [];
          description = ''
            The CPU pins to use.
          '';
        };
      };
    };
  };

  virtualStorage = mkOption {
    type = submodule {
      options = {
        type = mkOption {
          type = enum [ "qcow2" "raw" ];
          default = "qcow2";
          description = ''
            The type of storage to use.
          '';
        };

        size = mkOption {
          type = countUnitType;
          default = { unit = "G"; count = 32; };
          description = ''
            The size of the storage to use.
          '';
        };

        location = mkOption {
          type = path;
          default = null;
          description = ''
            The location of the storage to use.
          '';
        };
      };
    };
  };

  pciPassthrough = mkOption {
    type = submodule {
      options = {
        enable = mkOption {
          type = bool;
          default = false;
          description = ''
            Enable PCI passthrough.
          '';
        };

        addresses = mkOption {
          type = listOf str;
          default = [];
          description = ''
            The devices to passthrough.
          '';
        };
      };
    };
  };

  evdev = mkOption {
    type = listOf submodule {
      options = {
        path = mkOption {
          type = path;
          default = null;
          description = ''
            The path to the evdev device.
          '';
        };

        keyboard = mkOption {
          type = bool;
          default = false;
          description = ''
            Whether this is a keyboard device.
          '';
        };
      };
    };
    default = [];
  };

  spoof = mkOption {
    type = submodule {
      options = {
        uuid = mkOption {
          type = str;
          default = "abcd1234-abcd-1234-abcd-1234567890ab";
          description = ''
            The UUID to use.
          '';
        };

        sysinfo = mkOption {
          type = submodule {
            options = {
              bios = mkOption {
                type = submodule {
                  options = {
                    vendor = mkOption {
                      type = str;
                      default = "American Megatrends Inc.";
                      description = ''
                        The BIOS vendor to use.
                      '';
                    };

                    version = mkOption {
                      type = str;
                      default = "1.0.0";
                      description = ''
                        The BIOS version to use.
                      '';
                    };

                    date = mkOption {
                      type = str;
                      default = "01/01/2023";
                      description = ''
                        The BIOS date to use.
                      '';
                    };
                  };
                };
              };

              system = mkOption {
                type = submodule {
                  options = {
                    manufacturer = mkOption {
                      type = str;
                      default = "ASUSTeK COMPUTER INC.";
                      description = ''
                        The system manufacturer to use.
                      '';
                    };

                    product = mkOption {
                      type = str;
                      default = "ROG STRIX B560-F GAMING WIFI";
                      description = ''
                        The system product to use.
                      '';
                    };

                    version = mkOption {
                      type = str;
                      default = "Rev 1.xx";
                      description = ''
                        The system version to use.
                      '';
                    };

                    serial = mkOption {
                      type = str;
                      default = "1234567890";
                      description = ''
                        The system serial to use.
                      '';
                    };

                    sku = mkOption {
                      type = str;
                      default = "sku";
                      description = ''
                        The system SKU to use.
                      '';
                    };
                  };
                };
              };
            };
          }
        };

        mac = mkOption {
          type = str;
          default = "00:00:00:00:00:00";
          description = ''
            The MAC address to use.
          '';
        };

        diskSerial = mkOption {
          type = str;
          default = "01f4c755-1dc4-4d93-9343-8c3c65d20467";
          description = ''
            The disk serial to use.

            Serial Number Formats by Manufacture:
            Samsung: "XXXX_XXXX_XXXX_XXXX." - Characters: A-F 0-9
            Sandisk: "XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX." - Characters: A-F 0-9
          '';
        };

        chassis = mkOption {
          type = submodule {
            options = {
              serial = mkOption {
                type = str;
                default = "1234567890";
                description = ''
                  The chassis serial to use.
                '';
              };
            };
          }
        };

        processor = mkOption {
          type = submodule {
            options = {
              sockPfx = mkOption {
                type = str;
                default = "AM5";
                description = ''
                  The socket prefix.
                '';
              };
              maxSpeed = mkOption {
                type = int;
                default = 4400;
                description = ''
                  The max speed of the processor in MHz.
                '';
              };
              currentSpeed = mkOption {
                type = int;
                default = 3600;
                description = ''
                  The current speed of the processor in MHz.
                '';
              };
            };
          };
        };

        ram = mkOption {
          type = submodule {
            options = {
              locPfx = mkOption {
                type = str;
                default = "DIMM_B2";
                description = ''
                  The location prefix.
                '';
              };
              bank = mkOption {
                type = str;
                default = "BANK 3";
                description = ''
                  The bank to use.
                '';
              };
              manufacturer = mkOption {
                type = str;
                default = "Corsair";
                description = ''
                  The RAM manufacturer to use.
                '';
              };
              serial = mkOption {
                type = str;
                default = "00000000";
                description = ''
                  The RAM serial to use.
                '';
              };
              asset = mkOption {
                type = str;
                default = "Not Specified";
                description = ''
                  The RAM asset to use.
                '';
              };
              part = mkOption {
                type = str;
                default = "CMK32GX5M2B5600C36";
                description = ''
                  The RAM part to use.
                '';
              };
              speed = mkOption {
                type = int;
                default = 5600;
                description = ''
                  The RAM speed to use in MHz.
                '';
              };
            };
          };
        };
      };
    };
  };

  extraConfig = mkOption {
    type = attrsOf inferred;
    default = { };
    description = ''
      Extra configuration options for QEMU.
    '';
  };
}