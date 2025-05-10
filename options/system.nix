{ lib, helpers, ... }:

let
  mkOption = lib.mkOption;
in with helpers lib.types; {
  processorVendor = mkOption {
    type = enum [ "amd" "intel" ];
    default = "amd";
    description = ''
      The processor vendor to use.
    '';
  };
  pciPassthrough = mkOption {
    type = lib.types.submodule {
      options = {

        pciIds = mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = ''
            The PCI IDs to passthrough.
          '';
        };
      };
    };
  };
}