local g = vim.g

-- append a slash to folder names
g.nvim_tree_add_trailing = 1

-- close the tree after opening a file
g.nvim_tree_quit_on_open = 1

-- -- ignore things
g.nvim_tree_ignore = { '.git', '.cache' }
g.nvim_tree_gitignore = 1

require('nvim-tree').setup({
  update_focused_file = {
    enable = true,
  },
  view = {
    side = 'right',
    auto_resize = true,
    width = '35%'
  }
})
