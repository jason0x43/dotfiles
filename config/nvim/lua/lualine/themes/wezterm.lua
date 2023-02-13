local shift = require('user.util.theme').shift

local colors_text =
	vim.fn.readfile(os.getenv('HOME') .. '/.local/share/wezterm/colors.json')
local c = vim.fn.json_decode(colors_text)

local bg = c['bg']
local bg1 = shift(bg, -0.1)
local bg2 = shift(bg1, -0.1)
local blue = c['color12']
local green = c['color10']
local violet = c['color13']
local red = c['color09']
local fg = c['fg']
local dim = shift(fg, -0.25)

return {
  normal = {
    a = { fg = bg, bg = blue, gui = 'bold' },
    b = { fg = fg, bg = bg2 },
    c = { fg = fg, bg = bg1 },
  },

  insert = { a = { fg = bg, bg = green, gui = 'bold' } },

  visual = { a = { fg = bg, bg = violet, gui = 'bold' } },

  replace = { a = { fg = bg, bg = red, gui = 'bold' } },

  inactive = {
    a = { fg = bg, bg = bg1 },
    c = { fg = dim, bg = bg },
  },
}
