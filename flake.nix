{
  description = "Patches and templates for a stealthy QEMU/KVM setup.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvirt.url = "github:AshleyYakeley/NixVirt";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixvirt, ...}:
    let
      packages = import nixpkgs { system = "x86_64-linux"; };
      modules = import ./modules {
        inherit packages;
      };
    in
    {
      nixosModules.default = modules.nixosModule;
    };
}