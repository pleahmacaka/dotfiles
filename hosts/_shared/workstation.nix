{ pkgs, ... }:

{
  imports = [ ./desktop-graphical.nix ];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    configurationLimit = 10;
  };

  boot.kernel.sysctl."vm.swappiness" = 10;

  environment.systemPackages = with pkgs; [
    scrcpy
    android-tools
    incus
  ];

  users.users.pleahmacaka.extraGroups = [ "networkmanager" ];
}
