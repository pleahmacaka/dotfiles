{ ... }:

{
  imports = [
    ./services
  ];

  home.username = "pleahmacaka";
  home.stateVersion = "25.11";

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
      # for `github authentication, use 'gh auth login'`
      credential = {
        "https://github.com" = {
          helper = "!gh auth git-credential";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cls = "clear";
      dev = "nix develop -c zsh";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # Starship 설정 (핵심)
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      add_newline = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
