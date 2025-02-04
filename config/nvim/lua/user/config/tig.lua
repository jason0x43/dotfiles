local util = require('user.util')

util.user_cmd('Tig', function()
  Snacks.terminal('tig', {
    win = {
      border = 'rounded'
    }
  })
end)
