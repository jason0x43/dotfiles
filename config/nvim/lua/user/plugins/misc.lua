return {
  -- better start/end matching
  {
    'andymass/vim-matchup',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- JSON schemas
  'b0o/schemastore.nvim',

  -- better git diff views
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = true,
  },

  -- Git tools
  'tpope/vim-fugitive',

  -- Auto-set indentation
  {
    'tpope/vim-sleuth',

    config = function()
      -- Disable sleuth for markdown files as it slows the load time
      -- significantly
      vim.g.sleuth_markdown_heuristics = 0
    end,
  },
}
