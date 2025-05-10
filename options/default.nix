{ lib, ... }:

let
  helpers = import ./helpers.nix;
  imports = {
    inherit lib helpers;
  };
{
  patch = import ./patch.nix  imports;
  qemu = import ./qemu.nix imports;
  system = import ./system.nix imports;
  hybrid = import ./hybrid.nix imports;
}