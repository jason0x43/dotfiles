local M = {}

M.config = function()
  require('user.req')('nvim-tree', function(nvim_tree)
    nvim_tree.setup({
      update_focused_file = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
      view = {
        side = 'right',
        width = 40,
      },
      git = {
        ignore = true,
      },
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    })

    require('user.util').lmap('n', '<cmd>NvimTreeToggle<cr>')
  end)
end

return M
