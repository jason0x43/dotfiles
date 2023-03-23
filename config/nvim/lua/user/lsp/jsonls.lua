local config = {
  filetypes = { 'json', 'jsonc' },

	init_options = {
		-- disable formatting for JSON; we'll use prettier through null-ls instead
		provideFormatter = false
	}
}

local schemastore = require('schemastore')
if schemastore then
  config.settings = {
    json = {
      schemas = schemastore.json.schemas(),
      validate = { enable = true },
    },
  }
end

return { config = config }
