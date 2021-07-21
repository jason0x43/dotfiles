local util = require('util')

require('Navigator').setup()

util.keys.map('<C-j>', '<cmd>lua require("Navigator").down()<cr>')
util.keys.map('<C-h>', '<cmd>lua require("Navigator").left()<cr>')
util.keys.map('<C-k>', '<cmd>lua require("Navigator").up()<cr>')
util.keys.map('<C-l>', '<cmd>lua require("Navigator").right()<cr>')
