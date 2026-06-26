{
  programs.git = {
    enable = true;
    ignores = [
      ".omo"
      ".claude"
    ];
    settings = {
      user = {
        name = "PleahMaCaka";
        email = "pleahmacaka@gmail.com";
      };
      init.defaultBranch = "main";
      gitCredentialHelper = {
        enable = true;
      };
      credential = {
        "https://github.com".helper = "!gh auth git-credential";
        "https://huggingface.co".helper =
          ''!f() { test "$1" = get && echo username=hf && echo "password=$(hf auth token)"; }; f'';
      };
    };
  };
}
