{ config, pkgs, lib, wslEnable ? false, ... }:

let
  opt = cond: pkg: if cond then [ pkg ] else [ ];
  isWSL = wslEnable or false;
in
{
  imports = [
    ./services
  ];

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    socat
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "PleahMaCaka";
        email = "pleahmacaka@gmail.com";
      };
      init.defaultBranch = "main";
      gitCredentialHelper = {
        enable = true;
      };
      # for `gh auth login`
      credential = {
        "https://github.com" = {
          helper = "!gh auth git-credential";
        };
      };
    };
  };
}
