return {
  'zbirenbaum/copilot-cmp',

  event = 'BufEnter',

  dependencies = {
    'hrsh7th/nvim-cmp',
    {
      'zbirenbaum/copilot.lua',
      config = function()
        require('copilot').setup()
      end,
    },
  },

  config = function()
    require('copilot_cmp').setup()
  end,
}
