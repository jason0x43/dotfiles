local util = require('util')

-- provide an externally callable command that can be used to dynamically
-- update the scheme in running neovim sessions
util.cmd('UpdateColors', 'lua require("config.theme").update_theme()')
