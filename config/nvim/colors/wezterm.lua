local req = require('user.req')
local wezterm = req('user.colors.wezterm')
if not wezterm then
  print('Unable to load wezterm theme')
else
  wezterm.apply_theme()
end
