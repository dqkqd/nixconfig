{
  pkgs,
  lib,
  ...
}: {
  programs.zed-editor = {
    enable = true;

    # This populates the userSettings "auto_install_extensions"
    extensions = [
      "astro"
      "catppuccin"
      "catppuccin-icons"
      "dockerfile"
      "html"
      "marksman"
      "mdx"
      "sql"
      "toml"
      "vue"
      "comment"
      "csv"
      "markdownlint"
      "nix"
      "tombi"
      "just"
    ];

    # Everything inside of these brackets are Zed options
    userSettings = {
      load_direnv = "shell_hook";
      cli_default_open_behavior = "new_window";
      project_panel.dock = "left";
      outline_panel.dock = "left";
      collaboration_panel.dock = "left";
      git_panel.dock = "left";
      disable_ai = true;
      agent = {
        dock = "right";
        favorite_models = [];
        model_parameters = [];
      };
      title_bar = {
        show_user_menu = false;
        show_sign_in = false;
      };
      tabs = {
        file_icons = true;
        git_status = true;
        show_diagnostics = "all";
      };
      git = {
        inline_blame = {
          show_commit_summary = true;
        };
      };
      base_keymap = "VSCode";
      show_whitespaces = "all";
      relative_line_numbers = "wrapped";
      icon_theme = "Catppuccin Mocha";
      ui_font_size = 16;
      buffer_font_size = 15;
      vim_mode = true;
      inlay_hints = {
        enabled = true;
      };
      theme = {
        mode = "dark";
        light = "Catppuccin Latte - No Italics";
        dark = "Catppuccin Mocha - No Italics";
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };
      hour_format = "hour24";
      auto_update = false;

      lsp = {
        rust-analyzer = {
          binary = {
            # path = lib.getExe pkgs.rust-analyzer;
            path_lookup = true;
          };
        };
        nil = {
          binary = {
            path_lookup = true;
          };
        };
      };

      languages = {
        Markdown = {
          completions = {
            words = "enabled";
            words_min_length = 3;
            lsp = true;
            lsp_fetch_timeout_ms = 0;
            lsp_insert_mode = "replace_suffix";
          };
        };

        Nix = {
          language_servers = ["nil" "!nixd" "statix"];
          formatter = {
            external = {
              command = "alejandra";
              arguments = ["--quiet" "--"];
            };
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "shift shift" = "file_finder::Toggle";
        };
      }
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "r" = "project_panel::Rename";
          "space e" = "project_panel::Toggle";
        };
      }
      {
        context = "Editor && (showing_completions || showing_code_actions)";
        bindings = {
          "ctrl-n" = "editor::ContextMenuNext";
          "ctrl-p" = "editor::ContextMenuPrevious";
        };
      }
      {
        context = "Editor && vim_mode == normal";
        bindings = {
          "space 1" = ["pane::ActivateItem" 0];
          "space 2" = ["pane::ActivateItem" 1];
          "space 3" = ["pane::ActivateItem" 2];
          "space 4" = ["pane::ActivateItem" 3];
          "space 5" = ["pane::ActivateItem" 4];
          "space 6" = ["pane::ActivateItem" 5];
          "space 7" = ["pane::ActivateItem" 6];
          "space 8" = ["pane::ActivateItem" 7];
          "space 9" = ["pane::ActivateItem" 8];
          "space f f" = "file_finder::Toggle";
          "space s g" = "workspace::NewSearch";
          "space b l" = "pane::CloseItemsToTheRight";
          "space b h" = "pane::CloseItemsToTheLeft";
          "space e" = "project_panel::Toggle";
          "g j" = "editor::AddSelectionBelow";
          "g k" = "editor::AddSelectionAbove";
          "space c a" = "editor::ToggleCodeActions";
          "space c p" = "workspace::CopyRelativePath";
          "space f m" = "editor::Format";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
        };
      }
    ];
  };
}
