{ pkgs, wuw, claude-science, ... }:

let
  uid = 1001;
in
{
  wsl.defaultUser = "pleahmacaka";

  # WSL distros share one cgroup tree; 1000 collides with podman-machine-default.
  users.users.pleahmacaka.uid = uid;

  # That tree outlives a distro restart, and the leftover blocks the new user manager.
  systemd.services.prune-stale-user-cgroup = {
    wantedBy = [ "sysinit.target" ];
    before = [ "sysinit.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.findutils}/bin/find /sys/fs/cgroup/user.slice/user-${toString uid}.slice -depth -type d -exec rmdir {} +";
      SuccessExitStatus = "0 1";
    };
  };

  # WSL's resolv.conf would override the DNSSEC/DoT setup in nix-base.nix.
  wsl.wslConf.network.generateResolvConf = false;

  networking.networkmanager.enable = false;

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    wuw
    claude-science
    usbutils
    kmod
  ];
}
