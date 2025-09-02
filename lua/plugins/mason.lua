-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "shfmt",
        "shellcheck",
        "debugpy",
        "tree-sitter-cli",
        "pyright",
        "ruff",
        "nil",
        "nixfmt",
        "nixpkgs-fmt",
        "alejandra",
      },
    },
  },
}
