local denols = require('lspconfig.server_configurations.denols')
local lspconfig = require('lspconfig')

return {
  root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
  init_options = {
    lint = true,
    unstable = true,
  },
  handlers = {
    ['textDocument/definition'] = function(err, result, ctx)
      -- If denols returns multiple results, goto the first local one
      if result and #result > 1 then
        result = { result[1] }
      end
      denols.default_config.handlers['textDocument/definition'](
        err,
        result,
        ctx
      )
    end,
    ['textDocument/codeAction'] = function(err, result, ctx, config)
      print('handling deno codeaction')
      denols.default_config.handlers['textDocument/codeAction'](
        err,
        result,
        ctx,
        config
      )
    end,
  },
}
