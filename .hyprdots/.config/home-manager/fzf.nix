# ~/.config/home-manager/fzf/default.nix
{...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    # Default command for fzf when called without a pipe
    defaultCommand = "fd --type f --hidden --follow --exclude .git --exclude node_modules";

    # Global options for fzf's appearance and behavior
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview-window=right:60%:wrap"
      "--bind='ctrl-d:preview-page-down,ctrl-u:preview-page-up'"
      "--bind='ctrl-y:execute-silent(echo {} | xclip -selection clipboard)'" # Yank to clipboard
      "--bind='ctrl-e:execute($EDITOR {})'" # Open in editor
      "--ansi"
    ];

    # Specific options for the file selection widget (e.g., Ctrl+T)
    fileWidgetOptions = ["--preview 'bat --style=numbers --color=always {}'"];
  };

  # Custom Zsh functions, widgets, and key bindings
  programs.zsh.initContent = ''
    # Use bat for fzf's file preview
    export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && echo '{} is a binary file' || (bat --style=numbers --color=always {} || cat {}) 2>/dev/null | head -500"

    # ##############################################################################
    #
    # Fedora-specific FZF Functions for Zsh
    #
    # ##############################################################################

    # ------------------------------------------------------------------------------
    # DNF: List and manage installed DNF packages
    # ------------------------------------------------------------------------------
    function fzf-fedora-packages() {
        if ! (( $+commands[dnf] )); then
            echo "Error: DNF command not found." >&2
            return 1
        fi
        dnf list installed 2>/dev/null | \
            awk 'NR>1 {print $1}' | \
            sed 's/\.[^.]*$//' | \
            sort -u | fzf --multi \
            --preview 'dnf info {} 2>/dev/null || echo "Package info not available."' \
            --preview-window=right:50%:wrap \
            --header 'Installed DNF Packages' \
            --bind 'enter:execute(dnf info {})'
    }

    # ------------------------------------------------------------------------------
    # DNF: Search for available packages in repositories
    # ------------------------------------------------------------------------------
    function fzf-fedora-search() {
        local query
        # Read search query from the command-line buffer if present
        read -r -c 1 -q "?Search DNF for: " query && echo
        if [[ -z "$query" ]]; then return 0; fi

        if ! (( $+commands[dnf] )); then
            echo "Error: DNF command not found." >&2
            return 1
        fi
        dnf search "$query" 2>/dev/null | \
            grep -E '^[a-zA-Z0-9].*\..*:' | \
            awk '{print $1}' | \
            sed 's/\.[^.]*$//' | \
            sort -u | fzf --multi \
            --preview 'dnf info {} 2>/dev/null || echo "Package info not available."' \
            --preview-window=right:50%:wrap \
            --header "DNF Search Results for: $query" \
            --bind 'enter:execute(dnf info {})'
    }

    # ------------------------------------------------------------------------------
    # DNF: List available package updates
    # ------------------------------------------------------------------------------
    function fzf-fedora-updates() {
        if ! (( $+commands[dnf] )); then
            echo "Error: DNF command not found." >&2
            return 1
        fi
        dnf check-update 2>/dev/null | \
            awk 'NR>1 {print $1}' | \
            sed 's/\.[^.]*$//' | \
            sort -u | fzf --multi \
            --preview 'dnf info {} 2>/dev/null || echo "Package info not available."' \
            --preview-window=right:50%:wrap \
            --header 'Available DNF Updates' \
            --bind 'enter:execute(dnf info {})'
    }

    # ------------------------------------------------------------------------------
    # Flatpak: List and manage installed Flatpak applications
    # ------------------------------------------------------------------------------
    function fzf-fedora-flatpaks() {
        if ! (( $+commands[flatpak] )); then
            echo "Error: Flatpak command not found." >&2
            return 1
        fi
        flatpak list --app --columns=application 2>/dev/null | fzf --multi \
            --preview 'flatpak info {} 2>/dev/null || echo "Application info not available."' \
            --preview-window=right:50%:wrap \
            --header 'Installed Flatpak Applications' \
            --bind 'enter:execute(flatpak info {})'
    }

    # ------------------------------------------------------------------------------
    # Systemd: Manage system and user services
    # ------------------------------------------------------------------------------
    function fzf-fedora-services() {
        local service_type
        service_type=$(echo -e "system\nuser" | fzf --height=15% --header 'Select Service Type')
        if [[ -z "$service_type" ]]; then return 0; fi

        local systemctl_cmd="systemctl"
        [[ "$service_type" == "user" ]] && systemctl_cmd="systemctl --user"

        $systemctl_cmd list-units --type=service --all --no-pager --no-legend 2>/dev/null | \
            awk '{print $1}' | \
            grep '\.service$' | fzf --multi \
            --preview "$systemctl_cmd status {} 2>/dev/null || echo 'Service status not available'" \
            --preview-window=right:50%:wrap \
            --header "Systemd Services ($service_type)" \
            --bind "enter:execute($systemctl_cmd status {})"
    }

    # ##############################################################################
    # Zsh Widgets and Key Bindings
    # ##############################################################################

    # Widget to list installed packages
    fzf-fedora-packages-widget() {
      fzf-fedora-packages
      zle reset-prompt
    }
    zle -N fzf-fedora-packages-widget
    bindkey '^p' fzf-fedora-packages-widget      # Ctrl+P -> Packages

    # Widget to search for packages
    fzf-fedora-search-widget() {
      fzf-fedora-search
      zle reset-prompt
    }
    zle -N fzf-fedora-search-widget
    bindkey '^f' fzf-fedora-search-widget        # Ctrl+F -> Find/Search

    # Widget to manage systemd services
    fzf-fedora-services-widget() {
      fzf-fedora-services
      zle reset-prompt
    }
    zle -N fzf-fedora-services-widget
    bindkey '^s' fzf-fedora-services-widget      # Ctrl+S -> Services
  '';
}
