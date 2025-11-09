{ ... }:

{
  users.users.pleahmacaka = {
    isNormalUser = true;
    group = "pleahmacaka";
    extraGroups = [ "wheel" ];
    password = "nixos";
  };

  users.groups.pleahmacaka = { };
}
