local theme = require('user.themes.wezterm')
if not theme then
  print('Unable to load theme')
else
  theme.apply()
end
