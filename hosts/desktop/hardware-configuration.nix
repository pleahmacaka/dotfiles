{ ... }:

{
  # Placeholder hardware-configuration.
  # Replace this entire file with the output of `nixos-generate-config`
  # run on the actual desktop machine before deploying.
  imports = [ ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/PLACEHOLDER_ROOT";
    fsType = "ext4";
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
