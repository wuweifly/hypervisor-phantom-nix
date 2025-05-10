{ pkgs, cfg, lib, customPkgs, ... }:

let
  data = { inherit pkgs cfg lib customPkgs; };
  customPkgs = import ./pkgs.nix data;
  _ = import ./kernel.nix data;
  __ = import ./hooks.nix data;
{
  inherit customPkgs;

  templates = ./templates data;
}