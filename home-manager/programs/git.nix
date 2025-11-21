{
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
}
