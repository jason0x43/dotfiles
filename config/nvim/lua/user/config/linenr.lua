-- show line numbers if the window is wide enough
vim.opt.number = vim.go.columns >= 88

require('user.util').augroup('init_linenr', {
  -- show line numbers if the window is big enough
  'VimResized * lua vim.opt.number = vim.go.columns > 88',
});
