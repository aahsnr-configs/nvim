-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  { import = "astrocommunity.markdown-and-latex.markmap-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.markdown-and-latex.texpresso-vim" },
  { import = "astrocommunity.markdown-and-latex.vimtex" },
  { import = "astrocommunity.comment.ts-comments-nvim" },
  -- import/override with your plugins folder
}
