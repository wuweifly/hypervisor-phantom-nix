{ cfg, customPkgs, lib, ... }:

{
  win11 = import ./win11.nix {
    inherit cfg customPkgs lib;
  };
}