local theme = require('user.themes.terminal')
if not theme then
  print('Unable to load theme')
else
  theme.apply()
end
