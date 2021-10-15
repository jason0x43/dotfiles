local util = require('util')

require('Navigator').setup()

util.nmap('<C-j>', '<cmd>lua require("Navigator").down()<cr>')
util.nmap('<C-h>', '<cmd>lua require("Navigator").left()<cr>')
util.nmap('<C-k>', '<cmd>lua require("Navigator").up()<cr>')
util.nmap('<C-l>', '<cmd>lua require("Navigator").right()<cr>')
