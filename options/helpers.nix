{ lib, ... }:

{
  countUnitType = lib.types.submodule {
    options = {
      unit = mkOption {
        type = lib.types.str;
        default = "unit";
        description = ''
          The unit of the count.
        '';
      };

      count = mkOption {
        type = lib.types.int;
        default = 32;
        description = ''
          The count of the unit.
        '';
      };
    };
  };
  addressType = lib.types.submodule {
    options = {
      domain = mkOption {
        type = lib.types.int;
        default = "domain";
        description = ''
          The domain of the address.
        '';
      };
      bus = mkOption {
        type = lib.types.int;
        default = "bus";
        description = ''
          The bus of the address.
        '';
      };
      slot = mkOption {
        type = lib.types.int;
        default = "slot";
        description = ''
          The slot of the address.
        '';
      };
      function = mkOption {
        type = lib.types.int;
        default = "function";
        description = ''
          The function of the address.
        '';
      };
    };
  };
}