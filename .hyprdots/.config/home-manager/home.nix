{ pkgs, ... }: {
  home = {
    username = "ahsan";
    homeDirectory = "/home/ahsan";
    stateVersion = "25.11";
    extraOutputsToInstall = [ "doc" "info" "devdoc" ];

    # Set default editor and other environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "emacsclient -c -a 'emacs'";
      TERMINAL = "kitty";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      PAGER = "bat --paging=always --style=plain";
      LESS = "-R --use-color -Dd+r -Du+b -DS+s -DE+g";
      LANG = "en_US.UTF-8";
      FEDORA_RIPGREP_SPEC_PATHS =
        "/usr/src/packages/SPECS:/home/$USER/rpmbuild/SPECS";
      FEDORA_RIPGREP_SOURCE_PATHS =
        "/usr/src/packages/SOURCES:/home/$USER/rpmbuild/SOURCES";
      YAZI_CONFIG_HOME = "$HOME/.config/yazi";
      YAZI_FILE_ONE = "${pkgs.bat}/bin/bat --paging=never --color=always";
    };

    shell.enableZshIntegration = true;

    # Consolidate PATH from export.zsh
    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/.bun/bin"
      "$HOME/.local/bin"
      "$HOME/.local/bin/hypr"
      "$HOME/.config/emacs/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.local/share/flatpak/exports/bin"
    ];
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./catppuccin.nix
    ./dev.nix
    ./emoji.nix
    ./eza.nix
    ./fd-find.nix
    ./fonts.nix
    ./fzf.nix
    ./git.nix
    ./keyring.nix
    ./lazygit.nix
    ./pay-respects.nix
    ./pkgs.nix
    ./ripgrep.nix
    ./starship.nix
    ./tldr.nix
    ./yazi.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnfreePredicate = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
