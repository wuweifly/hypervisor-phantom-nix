{ lib, helpers, ... }:

let
  mkOption = lib.mkOption;
in with helpers lib.types; {
  hugePages = mkOption {
    type = lib.types.submodule {
      options = {
        enable = mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable huge pages.
          '';
        };

        number = mkOption {
          type = lib.types.int;
          default = 1024;
          description = ''
            The number of huge pages to use (default size 2 MiB).
          '';
        };
      };
    };
  };
  cpuPinning = mkOption {
    type = lib.types.submodule {
      options = {
        enable = mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable CPU pinning.
          '';
        };

        cores = mkOption {
          type = lib.types.listOf lib.types.int;
          default = [];
          description = ''
            The cores to pin.
          '';
        };

        release = mkOption {
          type = lib.types.listOf lib.types.str;
          default = "0-15";
          description = ''
            The cores to release.
          '';
        };
      };
    };
  };
  lookingGlass = mkOption {
    type = lib.types.submodule {
      options = {
        enable = mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable Looking Glass.
          '';
        };

        size = mkOption {
          type = lib.types.int;
          default = 32;
          description = ''
            The size of the Looking Glass in MB.
          '';
        };
      };
    };
  };
}