local util = require('util')

-- kill a buffer without closing its window
util.keys.lmap('k', ':Bdelete<cr>')
util.keys.lmap('K', ':Bdelete!<cr>')
