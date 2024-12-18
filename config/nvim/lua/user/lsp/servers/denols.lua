local lspconfig = require('lspconfig')

return {
  root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),

  init_options = {
    formatter = true,
    lint = true,
    unstable = true,
  },

  autostart = false,

  single_file_support = true,
}
