{ config, pkgs, ... }:
{
  home.stateVersion = "25.05";
  programs.git = {
    enable = true;
    userName = "PleahMaCaka";
    userEmail = "pleahmacaka@gmail.com";
    extraConfig = {
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

