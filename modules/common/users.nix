{ pkgs, ... }:

{
  users.users.pleahmacaka = {
    isNormalUser = true;
    group = "pleahmacaka";
    extraGroups = [ "wheel" ];
    password = "nixos";
    shell = pkgs.zsh;
  };

  system.userActivationScripts.zshrc = "touch ~/.zshrc";

  users.groups.pleahmacaka = { };
}
