{ config, lib, pkgs, ... }:

{

  boot = {
    kernelParams = [ "cma=512M" "console=ttymxc0,115200" "pci=nomsi" ];
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  environment.systemPackages = with pkgs; [ brightnessctl ];

  hardware.pulseaudio.daemon.config.default-sample-rate = lib.mkDefault "48000";

  nixpkgs = {
    system = "aarch64-linux";
    overlays = [
      (final: super:
        let inherit (final) callPackage;
        in { ubootReformImx8mq = callPackage ./u-boot { }; })
    ];
  };

  system.activationScripts.asound = ''
    if [ ! -e "/var/lib/alsa/asound.state" ]; then
      mkdir -p /var/lib/alsa
      cp ${./initial-asound.state} /var/lib/alsa/asound.state
    fi
  '';
}
