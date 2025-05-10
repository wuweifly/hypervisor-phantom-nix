{ pkgs, ... }:

let
  cfg = config.virtualisation.hypervisor-phantom;
  common = import ./common.nix {
    inherit pkgs cfg;
  };
{
  inherit common;

  nixosModule = import ./nixos.nix {
    inherit pkgs cfg;
  };
}