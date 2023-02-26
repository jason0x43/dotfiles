return {
  'zbirenbaum/copilot-cmp',

  event = 'BufEnter',

  dependencies = {
    'nvim-cmp',
    {
      'zbirenbaum/copilot.lua',
      config = function()
        require('copilot').setup({
          suggestion = {
            enabled = false,
            auto_trigger = true,
          },
          panel = { enabled = false },
        })
      end,
    },
  },

  config = function()
    require('copilot_cmp').setup()
  end,
}
