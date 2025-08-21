{...}: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      style = {
        description = {color = "#cad3f5";}; # Text
        command_name = {
          color = "#c6a0f6";
          style = "bold";
        }; # Mauve
        example_text = {color = "#cad3f5";}; # Text
        example_code = {color = "#a6da95";}; # Green
        example_variable = {
          color = "#ed8796";
          style = "italic";
        }; # Red
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 720; # Update cache every 30 days
      };
    };
  };

  programs.zsh = {
    enable = true;

    # One-to-one translation of your aliases
    shellAliases = {
      tl = "tldr";

      # Quick Fedora-specific command shortcuts
      tldr-dnf = "tldr dnf";
      tldr-rpm = "tldr rpm";
      tldr-flatpak = "tldr flatpak";
      tldr-systemctl = "tldr systemctl";
      tldr-firewall = "tldr firewall-cmd";
      tldr-selinux = "tldr semanage";
      tldr-podman = "tldr podman";

      # Package management workflow shortcuts
      help-install = "tldr dnf | grep -A5 -B5 install";
      help-update = "tldr dnf | grep -A5 -B5 update";
      help-search = "tldr dnf | grep -A5 -B5 search";
      help-remove = "tldr dnf | grep -A5 -B5 remove";
    };

    # One-to-one translation of your shell functions
    initContent = ''
      # Enhanced tldr functions for Fedora
      tldrf() {
          if [[ -n "$1" ]]; then
              # Fast local-only lookup
              tldr "$@" 2>/dev/null || echo "Command not found in cache. Try: tldr --update"
          else
              echo "Usage: tldrf <command>"
              echo "Fast tldr with local cache only"
          fi
      }

      # Search tldr pages
      tldr-search() {
          if [[ -n "$1" ]]; then
              tldr --list | grep -i "$1"
          else
              echo "Usage: tldr-search <pattern>"
              echo "Search available tldr pages"
          fi
      }

      # Integration with fzf for fuzzy searching
      tldr-fzf() {
          tldr --list | fzf --preview 'tldr {1}' --preview-window right:70%
      }

      # Integration with bat for syntax highlighting
      tldr-bat() {
          tldr "$1" | bat --language=markdown --style=plain
      }
    '';
  };
}
