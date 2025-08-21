# ~/.config/home-manager/ripgrep/default.nix
{...}: {
  # Enable ripgrep and configure its command-line arguments.
  programs.ripgrep = {
    enable = true;
    arguments = [
      # Performance optimizations
      "--max-columns=300"
      "--max-columns-preview"
      "--smart-case"
      "--one-file-system"
      "--mmap"
      "--max-depth=10"

      # Search preferences
      "--hidden"
      "--follow"

      # Globs to ignore
      "--glob=!.git/"
      "--glob=!.svn/"
      "--glob=!.hg/"
      "--glob=!CVS/"
      "--glob=!.idea/"
      "--glob=!.vscode/"
      "--glob=!*.min.*"
      "--glob=!*.o"
      "--glob=!*.so"
      "--glob=!*.pyc"
      "--glob=!__pycache__/"
      "--glob=!node_modules/"
      "--glob=!target/"
      "--glob=!*.swp"
      "--glob=!*.swo"
      "--glob=!*.aux"
      "--glob=!*.out"
      "--glob=!*.toc"
      "--glob=!*.blg"
      "--glob=!*.bbl"
      "--glob=!*.fls"
      "--glob=!*.fdb_latexmk"

      # Fedora-specific excludes
      "--glob=!*.rpm"
      "--glob=!*.dnf"
      "--glob=!*.cache"
      "--glob=!*.tmp"
      "--glob=!*.lock"
      "--glob=!*.log"
      "--glob=!*.pid"
      "--glob=!*.socket"
      "--glob=!*.service.d/"
      "--glob=!*.target.d/"
      "--glob=!/var/cache/dnf/"
      "--glob=!/var/lib/dnf/"
      "--glob=!/var/log/dnf*/"
      "--glob=!/var/lib/rpm/"
      "--glob=!/proc/"
      "--glob=!/sys/"
      "--glob=!/dev/"
      "--glob=!/run/"
      "--glob=!/tmp/"
      "--glob=!/boot/"
      "--glob=!/media/"
      "--glob=!/mnt/"

      # Custom file type definitions
      "--type-set=spec:*.spec"
      "--type-set=rpm:*.spec,*.changes,*.patch"
      "--type-set=fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount"
      "--type-set=dnf:*.repo,*.conf"
      "--type-set=kernel:*.config,*.patch,*.spec"
      "--type-set=systemd:*.service,*.target,*.mount,*.socket"
    ];
  };

  # Configure zsh integrations for ripgrep.
  programs.zsh = {
    shellAliases = {
      # General aliases
      rg-rpm = "rg --type rpm";
      rg-build = "rg --glob='*/BUILD/*' --glob='*/BUILDROOT/*'";
      rg-systemd = "rg --type systemd";

      # Fedora-specific aliases
      rgs = "rg --type fedora";
      rgd = "rg --type dnf";
      rgk = "rg --type kernel";
    };

    # Add helper functions to the zsh environment.
    initContent = ''
      # Ripgrep integration with fzf and bat preview
      if command -v rg &>/dev/null; then
          # Enhanced rg search with preview using fzf
          function rgfzf() {
              if ! command -v fzf &>/dev/null; then
                  echo "fzf not found. Please install fzf first."
                  return 1
              fi

              rg --color=always --heading --line-number "$@" | fzf --ansi \
                  --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
                  --preview-window 'right:60%:wrap' \
                  --delimiter ':' \
                  --bind 'enter:execute($''${EDITOR:-nvim} {1} +{2})'
          }

          # Search for contents and open in editor
          function rge() {
              if ! command -v fzf &>/dev/null; then
                  echo "fzf not found. Please install fzf first."
                  return 1
              fi

              local selected
              selected=$(rg --no-heading --line-number "$@" | fzf --ansi -0 -1)

              if [[ -n "$selected" ]]; then
                  local file=$(echo "$selected" | cut -d: -f1)
                  local line=$(echo "$selected" | cut -d: -f2)
                  $''${EDITOR:-nvim} "$file" +"$line"
              fi
          }

          # Search for files by name
          function rgfiles() {
              if ! command -v fzf &>/dev/null; then
                  echo "fzf not found. Please install fzf first."
                  return 1
              fi

              rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
          }

          # Use rg for zsh history search
          function history-rg() {
              history 1 | rg "$@"
          }

          # Use rg with bat for code search
          function rgg() {
              if command -v bat &>/dev/null; then
                  rg -p "$@" | bat --style=plain --color=always
              else
                  rg -p "$@" | less -RFX
              fi
          }
      fi
    '';
  };
}
