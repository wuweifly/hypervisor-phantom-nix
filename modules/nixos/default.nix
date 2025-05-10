{ pkgs, cfg, lib, ... }:

let
  data = { inherit pkgs cfg lib; };
  customPkgs = import ./pkgs.nix data;
  _ = import ./kernel.nix data;
  __ = import ./hooks.nix data;
{
  inherit customPkgs;
}