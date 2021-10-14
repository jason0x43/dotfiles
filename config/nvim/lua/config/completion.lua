local exports = {}

vim.opt.completeopt = { 'menu', 'noinsert', 'noselect', 'menuone' }

local function key(key_code)
  return vim.api.nvim_replace_termcodes(key_code, true, false, true)
end

function exports.complete(direction)
  if vim.fn.pumvisible() == 1 then
    if direction == 1 then
      return key('<c-n>')
    end
    return key('<c-p>')
  end

  local min_chars = 2
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local last_chars = line:sub(col - min_chars, col)
  if not last_chars:match('%w%w') then
    return key('<tab>')
  end

  -- open the completion popup
  vim.api.nvim_feedkeys(key('<c-n>'), 'm', true)

  -- if omnifunc is setup for lsp, call the lsp completer
  if vim.bo.omnifunc == 'v:lua.vim.lsp.omnifunc' then
    vim.lsp.omnifunc(0, '')
  end

  return ''
end

-- manual completion and cycling
local util = require('util')
util.imap('<tab>', 'v:lua.completion.complete(1)', { expr = true })
util.imap('<s-tab>', 'v:lua.completion.complete(-1)', { expr = true })

-- automatic completion
util.augroup('custom-completion', {
  'TextChangedI *.md lua completion.complete(0)',
})

_G.completion = exports

return exports
