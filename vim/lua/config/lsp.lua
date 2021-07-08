if vim.g.use_native_lsp then
  require('plugins.nvim-lsp')
  require('plugins.nvim-compe')
else
  require('plugins.coc')
end
