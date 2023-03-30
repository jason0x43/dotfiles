return {
  -- highlight color strings
  {
    'norcalli/nvim-colorizer.lua',
    cond = vim.go.termguicolors,
    config = function()
      require('colorizer').setup({ '*' }, {
        names = false,
        rgb_fn = true,
      })
    end,
  },

  -- Better UI
  'stevearc/dressing.nvim',

	-- Popup notifications
	{
		'rcarriga/nvim-notify',

		opts = function()
			vim.notify = require('notify')
			return {
				timeout = 1000
			}
		end
	},

  -- highlight current word
  {
    'tzachar/local-highlight.nvim',
    opts = function()
      vim.api.nvim_set_hl(0, 'LocalHighlight', { link = 'CursorLine' })
      return {
        cw_hlgroup = 'LocalHighlight',
      }
    end,
  },

}
