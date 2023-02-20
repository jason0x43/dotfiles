local load_colors = require('user.themes.wezterm').load_colors

return {
  'utilyre/barbecue.nvim',
  name = 'barbecue',
	enabled = false,
  version = '*',
  dependencies = {
    'SmiteshP/nvim-navic',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
		local c = load_colors()

    require('barbecue').setup({
      theme = {
        normal = { bg = c.bg_1 },
      },
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('barbecue.colorizer', {}),
      callback = function()
				c = load_colors()
				require('barbecue').setup({
					theme = {
						normal = { bg = c.bg_1 },
					},
				})
      end,
    })
  end,
}
