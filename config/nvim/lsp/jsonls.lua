local C = require('user.util.lsp').make_config()

C.filetypes = { 'json', 'jsonc' }
C.init_options = {
  -- disable formatting for JSON; we'll use prettier through null-ls instead
  provideFormatter = false,
}

local schemastore = require('schemastore')
if schemastore then
  C.settings = {
    json = {
      schemas = schemastore.json.schemas(),
      validate = { enable = true },
    },
  }
end

return C
