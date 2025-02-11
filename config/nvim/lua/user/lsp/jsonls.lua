local C = require('user.util.lsp').make_user_config()

C.config.filetypes = { 'json', 'jsonc' }
C.config.init_options = {
  -- disable formatting for JSON; we'll use prettier through null-ls instead
  provideFormatter = false,
}

local schemastore = require('schemastore')
if schemastore then
  C.config.settings = {
    json = {
      schemas = schemastore.json.schemas(),
      validate = { enable = true },
    },
  }
end

return C
