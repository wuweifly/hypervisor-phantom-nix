{ pkgs, cfg, lib, ... }:

let
  cpuPinning = cfg.hybrid.cpuPinning;
{
  virtualisation.libvirtd.hooks.qemu = lib.mkIf cpuPinning.enable {
    "cpu-isolate" = lib.getExe (
      pkgs.writeShellApplication {
        name = "qemu-hook";

        runtimeInputs = [
          pkgs.systemd
        ];

        text = ''
          #!/bin/sh

          command=$2

          if [ "$command" = "started" ]; then
            systemctl set-property --runtime -- system.slice AllowedCPUs=${cpuPinning.cores}
            systemctl set-property --runtime -- user.slice AllowedCPUs=${cpuPinning.cores}
            systemctl set-property --runtime -- init.scope AllowedCPUs=${cpuPinning.cores}
          elif [ "$command" = "release" ]; then
            systemctl set-property --runtime -- system.slice AllowedCPUs=${cpuPinning.release}
            systemctl set-property --runtime -- user.slice AllowedCPUs=${cpuPinning.release}
            systemctl set-property --runtime -- init.scope AllowedCPUs=${cpuPinning.release}
          fi
        '';
      }
    );
  };
}