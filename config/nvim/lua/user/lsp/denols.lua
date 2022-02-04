local M = {}

local denols = require('lspconfig.server_configurations.denols')
local lspconfig = require('lspconfig')
local lsp_util = require('user.lsp.util')

M.config = {
  autostart = false,
  root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),

  init_options = {
    lint = true,
    unstable = true,
  },

  on_new_config = function(config, root_dir)
    local import_map = root_dir .. '/import_map.json'
    if vim.fn.filereadable(import_map) then
      config.init_options.importMap = import_map
    end
  end,

  handlers = {
    ['textDocument/definition'] = function(err, result, ctx, config)
      -- If denols returns multiple results, goto the first local one
      if result and #result > 1 then
        result = { result[1] }
      end
      denols.default_config.handlers['textDocument/definition'](
        err,
        result,
        ctx,
        config
      )
    end,
  },
}

M.start = lsp_util.create_start('denols')

lsp_util.create_autostart_autocmd('denols', require('user.util').ts_types)

return M
