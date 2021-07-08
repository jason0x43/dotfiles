local util = require('util')
local g = vim.g

-- show hierarchy lines
g.nvim_tree_indent_markers = 1

-- append a slash to folder names
g.nvim_tree_add_trailing = 1

-- close the tree after opening a file
g.nvim_tree_auto_close = 1

-- open the tree on the right side
g.nvim_tree_side = 'right'

-- wider tree
g.nvim_tree_width = '30%'

util.keys.lmap('n', ':NvimTreeFindFile<CR>')
