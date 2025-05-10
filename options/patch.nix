{ lib, ... }:

let
  mkOption = lib.mkOption;
in with lib.types; {
  acpi = mkOption {
    type = bool;
    default = false;
    description = ''
      Enable the ACPI patches.

      Current patches:
      - fake_battery - for laptops only
    '';
  };

  edk2 = mkOption {
    type = submodule {
      options = {
        enable = mkOption {
          type = bool;
          default = false;
          description = ''
            Enable the EDK2 (firmware) patches.
          '';
        };

        secureBoot = mkOption {
          type = bool;
          default = false;
          description = ''
            Enable secure boot.
          '';
        };
      };
    };
    description = ''
      Enable the EDK2 (firmware) patches, with secure boot.

      Current patches:
      - none
    '';
  };

  kernel = mkOption {
    type = bool;
    default = false;
    description = ''
      Enable the kernel patches.
    '';
  };

  qemu = mkOption {
    type = submodule {
      options = {
        enable = mkOption {
          type = bool;
          default = false;
          description = ''
            Enable the QEMU patches.

            Current patches:
            - none
          '';
        };

        processor = mkOption {
          type = submodule {
            options = {
              family = mkOption {
                type = str;
                default = "host";
                description = ''
                  The CPU family to use.
                '';
              };

              name = mkOption {
                type = str;
                default = "host";
                description = ''
                  The CPU name to use.
                '';
              };
            };
          };
        };
      };
    };
  };
}