{...}: {
  programs.fd = {
    enable = true;
    extraOptions = ["--no-ignore" "--absolute-path"];
    hidden = true;
    ignores = [".git/" "*.bak"];
  };
}
