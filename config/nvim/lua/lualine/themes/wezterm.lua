local load_colors = require('user.themes.wezterm').load_colors

local c = load_colors()

return {
  normal = {
    a = { fg = c.bg_0, bg = c.blue, gui = 'bold' },
    b = { fg = c.fg_0, bg = c.bg_2 },
    c = { fg = c.fg_0, bg = c.bg_1 },
  },

  insert = { a = { fg = c.bg_0, bg = c.green, gui = 'bold' } },

  visual = { a = { fg = c.bg_0, bg = c.violet, gui = 'bold' } },

  replace = { a = { fg = c.bg_0, bg = c.red, gui = 'bold' } },

  inactive = {
    a = { fg = c.bg_0, bg = c.bg_1 },
    c = { fg = c.dim_0, bg = c.bg_0 },
  },
}
