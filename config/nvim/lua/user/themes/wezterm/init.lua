local os = require('os')

local M = {}

local function load_colors()
  local colors_text =
    vim.fn.readfile(os.getenv('HOME') .. '/.local/share/wezterm/colors.json')
  return vim.fn.json_decode(colors_text)
end

function M.apply(appearance)
  local g = vim.g

  if appearance ~= nil and vim.go.background ~= appearance then
    vim.go.background = appearance
    return
  end

  local colors = load_colors()

	-- vim.go.background = colors.is_dark and 'dark' or 'light'

	if colors.type == 'selenized' then
		require('user.themes.wezterm.selenized').apply(colors.variant)
	elseif colors.type == 'base16' then
		require('user.themes.wezterm.base16').apply(colors)
	elseif colors.type == 'catppuccin' then
		require('user.themes.wezterm.catppuccin').apply(colors.variant)
	end

	require('lualine').setup({
		options = {
			theme = 'wezterm',
		},
	})
end

return M
