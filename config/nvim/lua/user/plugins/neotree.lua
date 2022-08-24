local M = {}

M.config = function()
  vim.g.neo_tree_remove_legacy_commands = 1
  vim.cmd('highlight link NeoTreeFloatBorder NormalFloat')

  require('neo-tree').setup({
    enable_git_status = true,
    popup_border_style = 'solid',
    window = {
      position = 'right'
    },
    event_handlers = {
      {
        event = 'file_opened',
        handler = function()
          require('neo-tree').close_all()
        end
      }
    }
  })

  require('user.util').lmap('n', '<cmd>Neotree reveal toggle<cr>')
end

return M
