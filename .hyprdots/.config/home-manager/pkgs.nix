{ pkgs, ... }: {
  home.packages = with pkgs; [
    delta
    lua5_1
    fastfetch
    luarocks
    emacs-lsp-booster
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    nil
    nixfmt
    nixpkgs-fmt
    nodejs_24
    proselint
    python313Packages.kde-material-you-colors
    tectonic
    texlab
    textlint
  ];
}
