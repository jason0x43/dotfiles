local util = require('util')

require('Navigator').setup()

util.map('<C-j>', '<cmd>lua require("Navigator").down()<cr>')
util.map('<C-h>', '<cmd>lua require("Navigator").left()<cr>')
util.map('<C-k>', '<cmd>lua require("Navigator").up()<cr>')
util.map('<C-l>', '<cmd>lua require("Navigator").right()<cr>')
