local M = {}

M.config = function()
  vim.g.neo_tree_remove_legacy_commands = 1

  require('neo-tree').setup({
    enable_git_status = true,

    popup_border_style = 'rounded',

    event_handlers = {
      {
        event = 'file_opened',
        handler = function()
          require('neo-tree').close_all()
        end
      }
    },

    window = {
      position = 'right'
    },
  })

  require('user.util').lmap('n', '<cmd>Neotree reveal toggle<cr>')
end

return M
