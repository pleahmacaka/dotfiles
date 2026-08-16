{ ... }:

{
  hardware.raspberry-pi.config.all.base-dt-params.pciex1.enable = true;

  boot.initrd.availableKernelModules = [ "nvme" ];
}
