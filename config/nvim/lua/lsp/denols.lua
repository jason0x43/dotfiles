local M = {}

local denols = require('lspconfig.server_configurations.denols')
local lspconfig = require('lspconfig')

local denoconfig = vim.fn.findfile('deno.json', '.;')
if denoconfig ~= '' then
  denoconfig = vim.fn.fnamemodify(denoconfig, ':p')
end

M.config = {
  single_file_support = true,

  root_dir = lspconfig.util.root_pattern('deno.json'),

  init_options = {
    lint = true,
    unstable = true,
    config = denoconfig
  },

  should_attach = function()
    return vim.fn.findfile('deps.ts', '.;') ~= ''
      or vim.fn.findfile('mod.ts', '.;') ~= ''
      or (
        vim.fn.findfile('tsconfig.json', '.;') == ''
        and vim.fn.findfile('jsconfig.json', '.;') == ''
      )
  end,

  on_attach = function()
    vim.cmd('autocmd BufWritePre <buffer> lua require("lsp").format_sync(nil, 5000)')
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

return M
