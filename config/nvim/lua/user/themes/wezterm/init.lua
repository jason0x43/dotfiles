local os = require('os')

local M = {}
local theme_util = require('user.util.theme')

local function load_scheme()
  local colors_text =
    vim.fn.readfile(os.getenv('HOME') .. '/.local/share/wezterm/colors.json')
  return vim.fn.json_decode(colors_text)
end

local active_palette = load_scheme()

function M.apply(appearance)
  local g = vim.g

  if appearance ~= nil and vim.go.background ~= appearance then
    vim.go.background = appearance
    return
  end

  active_palette = load_scheme()
  local palette = active_palette

  g.colors_name = palette.name

  g.terminal_color_0 = palette.color00
  g.terminal_color_1 = palette.color01
  g.terminal_color_2 = palette.color02
  g.terminal_color_3 = palette.color03
  g.terminal_color_4 = palette.color04
  g.terminal_color_5 = palette.color05
  g.terminal_color_6 = palette.color06
  g.terminal_color_7 = palette.color07
  g.terminal_color_8 = palette.color08
  g.terminal_color_9 = palette.color09
  g.terminal_color_10 = palette.color10
  g.terminal_color_11 = palette.color11
  g.terminal_color_12 = palette.color12
  g.terminal_color_13 = palette.color13
  g.terminal_color_14 = palette.color14
  g.terminal_color_15 = palette.color15

	if palette.type == 'selenized' then
		require('user.themes.wezterm.selenized').apply(palette)
	elseif palette.type == 'base16' then
		require('user.themes.wezterm.base16').apply(palette)
	else
		require('user.themes.wezterm.terminal').apply(palette)
	end
end

function M.active_palette()
  return active_palette
end

return M
