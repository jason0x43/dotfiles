return {
  -- file explorer in sidebar
  {
    'nvim-neo-tree/neo-tree.nvim',

    keys = {
      {
        '<leader>n',
        function()
          require('neo-tree').reveal_current_file(
            'filesystem',
            true,
            '<bang>' == '!'
          )
        end,
        desc = 'NeoTree',
      },
    },

    branch = 'v2.x',

    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },

    opts = function()
      vim.g.neo_tree_remove_legacy_commands = 1

      return {
        enable_git_status = true,

        popup_border_style = 'rounded',

        event_handlers = {
          {
            event = 'file_opened',
            handler = function()
              require('neo-tree').close_all()
            end,
          },
        },

        window = {
          position = 'right',
        },
      }
    end,
  },
}
