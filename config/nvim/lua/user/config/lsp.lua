---@module "user.config.lsp"

-- Logging
vim.lsp.set_log_level('error')
vim.lsp.log.set_format_func(vim.inspect)

vim.lsp.config('ts_ls', {
  root_markers = { 'tsconfig.json', 'jsonconfig.json' },
});

-- Give signature and hover floats a rounded border
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'
  opts.max_width = vim.api.nvim_win_get_width(0) - 10

  local bufnr, winid = orig_util_open_floating_preview(contents, syntax, opts, ...)
  vim.api.nvim_set_option_value('linebreak', true, { win = winid })

  return bufnr, winid
end

-- When an lsp returns multiple "goto definition" results, only keep the
-- first one
local origTextDocDef = vim.lsp.handlers['textDocument/definition']
vim.lsp.handlers['textDocument/definition'] = function(err, result, ctx, config)
  if result ~= nil and #result > 1 then
    result = { result[1] }
  end
  origTextDocDef(err, result, ctx, config)
end

-- Manually enable language servers not managed by Mason
vim.lsp.enable("sourcekit");
