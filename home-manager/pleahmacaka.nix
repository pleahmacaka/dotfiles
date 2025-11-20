{ ... }:

{
  imports = [
    ./services
  ];

  home.stateVersion = "unstable";

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

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableTransience = true;
    settings = {
      add_newline = true;
    };
  };
}
