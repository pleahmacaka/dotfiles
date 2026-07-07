{ pkgs, ... }:

{
  users.users.pleahmacaka = {
    isNormalUser = true;
    group = "pleahmacaka";
    extraGroups = [ "wheel" ];
    password = "nixos";
    shell = pkgs.zsh;
  };

  users.groups.pleahmacaka = { };
}
