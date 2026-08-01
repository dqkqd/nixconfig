let
  user = {
    name = "Khanh Duong";
    email = "dqkqdlot@gmail.com";
  };

  editor = "nvim";
  signingKey = "255D6E84B9AE57DA";
in {
  programs.git = {
    enable = true;

    settings = {
      inherit user;

      core.editor = editor;
    };

    signing = {
      key = signingKey;
      signByDefault = true;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      inherit user;

      signing = {
        behavior = "own";
        backend = "gpg";
      };

      template-aliases = {
        "format_short_id(id)" = "id.shortest()";
      };

      git = {
        abandon-unreachable-commits = true;
        colocate = true;
      };

      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };

      ui.editor = editor;
    };
  };
}
