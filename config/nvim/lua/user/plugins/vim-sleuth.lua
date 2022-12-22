-- autodetect buffer formatting
return {
  'tpope/vim-sleuth',

  config = function()
    -- Disable sleuth for markdown files as it slows the load time
    -- significantly
    vim.g.sleuth_markdown_heuristics = 0
  end,
}
