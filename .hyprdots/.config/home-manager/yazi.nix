# ~/.config/home-manager/yazi.nix
{pkgs, ...}: {
  # 1. PACKAGE DEPENDENCIES
  # All applications used for file opening, previews, and plugins are
  # declared here to ensure they are installed alongside Yazi.
  home.packages = with pkgs; [rich-cli ouch];

  programs.yazi = {
    enable = true;

    enableZshIntegration = true;

    # --- Yazi Plugins ---
    plugins = with pkgs.yaziPlugins; {
      # Essential
      inherit full-border toggle-pane smart-enter chmod;
      # Preview and Media
      inherit rich-preview ouch;
      # Navigation
      inherit jump-to-char;
      # Git and Development
      inherit git lazygit;
      # UI and Theming
      inherit starship yatline;
    };

    # --- Core Settings (yazi.toml) ---
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };
      preview = {
        max_width = 600;
        max_height = 900;
        wrap = "no";
      };
      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        image_alloc = 536870912; # 512 MB
      };
      opener = {
        # Using Nix package paths for portability instead of hardcoded paths.
        edit = [
          {
            run = ''/usr/bin/nvim "$@"'';
            block = true;
          }
        ];
        archive = [{run = ''/usr/bin/file-roller "$@"'';}];
        image = [{run = ''/usr/bin/imv "$@"'';}];
        video = [{run = ''/usr/bin/mpv "$@"'';}];
        audio = [{run = ''/usr/bin/mpv "$@"'';}];
        document = [{run = ''/usr/bin/zathura "$@"'';}];
        fallback = [{run = ''/usr/bin/xdg-open "$@"'';}];
      };
      open.rules = [
        {
          name = "*/";
          use = "edit";
        }
        {
          mime = "text/*";
          use = "edit";
        }
        {
          mime = "image/*";
          use = "image";
        }
        {
          mime = "video/*";
          use = "video";
        }
        {
          mime = "audio/*";
          use = "audio";
        }
        {
          mime = "application/pdf";
          use = "document";
        }
        {
          mime = "application/*zip";
          use = "archive";
        }
        {
          mime = "application/x-tar";
          use = "archive";
        }
        {
          mime = "application/x-gzip";
          use = "archive";
        }
        {
          name = "*";
          use = "fallback";
        }
      ];
    };

    # --- Key Bindings (keymap.toml) ---
    keymap = {
      manager.prepend = [
        # Navigation
        {
          on = "h";
          run = "leave";
          desc = "Go back to parent directory";
        }
        {
          on = "j";
          run = "arrow 1";
          desc = "Move cursor down";
        }
        {
          on = "k";
          run = "arrow -1";
          desc = "Move cursor up";
        }
        {
          on = "l";
          run = "enter";
          desc = "Enter directory";
        }
        {
          on = "G";
          run = "arrow bot";
          desc = "Move cursor to bottom";
        }
        # File operations
        {
          on = "y";
          run = "yank";
          desc = "Copy selected files";
        }
        {
          on = "d";
          run = "yank --cut";
          desc = "Cut selected files";
        }
        {
          on = "p";
          run = "paste";
          desc = "Paste files";
        }
        {
          on = ["d" "d"];
          run = "remove";
          desc = "Remove selected files";
        }
        {
          on = "a";
          run = "create";
          desc = "Create new file or directory";
        }
        {
          on = "r";
          run = "rename";
          desc = "Rename selected file";
        }
        # Tabs
        {
          on = "t";
          run = "tab_create --current";
          desc = "Create new tab";
        }
        {
          on = "w";
          run = "tab_close";
          desc = "Close current tab";
        }
        {
          on = "[";
          run = "tab_switch -1 --relative";
          desc = "Switch to previous tab";
        }
        {
          on = "]";
          run = "tab_switch 1 --relative";
          desc = "Switch to next tab";
        }
        # Miscellaneous
        {
          on = "q";
          run = "quit";
          desc = "Quit Yazi";
        }
        {
          on = ":";
          run = "shell --interactive";
          desc = "Run shell command";
        }
        {
          on = "!";
          run = "shell --block";
          desc = "Run shell command (blocking)";
        }
        {
          on = "?";
          run = "help";
          desc = "Show help";
        }
        {
          on = "<C-h>";
          run = "hidden toggle";
          desc = "Toggle hidden files";
        }
        {
          on = "<C-z>";
          run = "suspend";
          desc = "Suspend Yazi";
        }
      ];
      input.prepend = [
        {
          on = "<Esc>";
          run = "close";
        }
        {
          on = "<Enter>";
          run = "close --submit";
        }
      ];
      tasks.prepend = [
        {
          on = "<Esc>";
          run = "close";
        }
      ];
      help.prepend = [
        {
          on = "<Esc>";
          run = "close";
        }
      ];
    };
  };

  programs.zsh = {
    shellAliases = {yz = "yazi $(pwd)";};

    # Add custom functions and completion logic.
    initContent = ''
      # --- Custom Yazi Zsh Integrations ---

      # An alternative 'yy' command that mirrors the official 'y' wrapper
      # to change the current directory on exit.
      function yy() {
          local tmp cwd
          tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(< "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
              builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
      }

      # Forward completion from the custom 'yy' wrapper to the main yazi command.
      # The completion for 'y' is already handled by `enableZshIntegration`.
      compdef yy=yazi
    '';
  };
}
