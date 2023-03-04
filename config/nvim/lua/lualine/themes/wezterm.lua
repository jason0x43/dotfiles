local load_colors = require('user.themes.wezterm').load_colors

local c = load_colors()

return {
  normal = {
    a = { fg = c.blue, gui = 'bold,reverse' },
    b = { fg = c.fg_0, bg = c.bg_2 },
    c = { fg = c.fg_0, bg = c.bg_1 },
  },

  insert = { a = { fg = c.green, gui = 'bold,reverse' } },

  visual = { a = { fg = c.violet, gui = 'bold,reverse' } },

  replace = { a = { fg = c.red, gui = 'bold,reverse' } },

  inactive = {
    a = { fg = c.bg_0, bg = c.bg_1 },
    c = { fg = c.dim_0, bg = c.bg_0 },
  },
}
