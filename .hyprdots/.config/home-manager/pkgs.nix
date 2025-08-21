{ pkgs, ... }: {
  home.packages = with pkgs; [
    alejandra
    delta
    lua5_1
    fastfetch
    luarocks
    emacs-lsp-booster
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
