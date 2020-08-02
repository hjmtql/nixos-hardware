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
        in {

          linuxPackages_imx8mq = final.linuxPackagesFor
            (callPackage ./kernel { kernelPatches = [ ]; });

          ubootReformImx8mq = callPackage ./u-boot { };

        })
    ];
  };

  services.udev.extraRules =
    # Use the battery-backed RTC on the motherboard as the system clock
    ''
      KERNEL=="rtc1", SUBSYSTEM=="rtc", ATTR{name}=="rtc-pcf8523*", SYMLINK="rtc"
    '';

  system.activationScripts.asound = ''
    if [ ! -e "/var/lib/alsa/asound.state" ]; then
      mkdir -p /var/lib/alsa
      cp ${./initial-asound.state} /var/lib/alsa/asound.state
    fi
  '';
}
