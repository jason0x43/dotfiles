local util = require('util')

-- show hierarchy lines
vim.g.nvim_tree_indent_markers = 1

-- append a slash to folder names
vim.g.nvim_tree_add_trailing = 1

-- close the tree after opening a file
vim.g.nvim_tree_auto_close = 1

util.keys.lmap('n', ':NvimTreeFindFile<CR>')
