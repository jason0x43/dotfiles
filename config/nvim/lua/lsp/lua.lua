local exports = {}

exports.config = {
  settings = {
    Lua = { diagnostics = { globals = { 'hs', 'vim', 'packer_plugins' } } },
  },
}

return exports
