vim.o.completeopt = 'menuone,noselect'

require('compe').setup(
  {
    enabled = true,
    autocomplete = true,
    source = { path = true, nvim_lsp = true, nvim_lua = true, ultisnips = true }
  }
)

util.keys.imap('<cr>', 'compe#confirm("<cr>")', { expr = true })
