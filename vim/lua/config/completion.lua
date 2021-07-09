vim.g.completion_enabled_snippet = 'UltiSnips'
vim.g.completion_auto_change_source = 1
vim.g.completion_chain_complete_list = {
  default = {
    { complete_items = { 'lsp', 'snippet', 'path' } },
    { mode = '<c-n>' },
    { mode = '<c-p>' }
  },
  gitcommit = { { mode = '<c-n>' }, { mode = '<c-p>' } },
  vim = { { complete_items = { 'lsp', 'snippet', 'path' } }, { mode = 'cmd' } },
  c = { { complete_items = { 'ts' } } },
  python = { { complete_items = { 'lsp', 'snippet', 'path', 'ts' } } },
  lua = { { complete_items = { 'lsp', 'snippet', 'path', 'ts' } } },
  typescript = { { complete_items = { 'lsp', 'snippet', 'path', 'ts' } } },
  typescriptreact = { { complete_items = { 'lsp', 'snippet', 'path', 'ts' } } }
}
