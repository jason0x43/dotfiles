local shift = require('user.util.theme').shift
local load_colors = require('user.themes.wezterm').load_colors

local c = load_colors()
local bg = c.bg_0
local bg1 = shift(bg, -0.1)
local bg2 = shift(bg1, -0.1)
local blue = c.blue
local green = c.green
local violet = c.violet
local red = c.red
local fg = c.fg_0
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
