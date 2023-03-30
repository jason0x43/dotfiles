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

  -- symbol browser
  {
    'stevearc/aerial.nvim',

    opts = function()
      vim.keymap.set('n', '<leader>s', function()
        require('aerial').toggle({ focus = true })
      end)

      vim.api.nvim_set_hl(0, 'AerialLine', { link = 'CursorLine' })

      return {
        close_on_select = true,
        layout = {
          max_width = 0.3,
          width = 30,
        },
      }
    end,
  },
}
