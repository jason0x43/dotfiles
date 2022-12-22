return {
  'zbirenbaum/copilot-cmp',
  config = function()
    require('copilot_cmp').setup()
  end,
  dependencies = {
    'hrsh7th/nvim-cmp',
    {
      'zbirenbaum/copilot.lua',
      event = { 'VimEnter' },
      config = function()
        vim.defer_fn(function()
          require('copilot').setup()
        end, 100)
      end,
    },
  },
}
