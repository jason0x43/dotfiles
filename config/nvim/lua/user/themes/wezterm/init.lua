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

	vim.go.background = colors.is_dark and 'dark' or 'light'

  g.colors_name = colors.name

  g.terminal_color_0 = colors.color00
  g.terminal_color_1 = colors.color01
  g.terminal_color_2 = colors.color02
  g.terminal_color_3 = colors.color03
  g.terminal_color_4 = colors.color04
  g.terminal_color_5 = colors.color05
  g.terminal_color_6 = colors.color06
  g.terminal_color_7 = colors.color07
  g.terminal_color_8 = colors.color08
  g.terminal_color_9 = colors.color09
  g.terminal_color_10 = colors.color10
  g.terminal_color_11 = colors.color11
  g.terminal_color_12 = colors.color12
  g.terminal_color_13 = colors.color13
  g.terminal_color_14 = colors.color14
  g.terminal_color_15 = colors.color15

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
