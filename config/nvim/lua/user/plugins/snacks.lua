local util = require('user.util')

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = function()
      require('snacks')

      util.user_cmd('Highlights', function()
        Snacks.picker.highlights()
      end)

      util.user_cmd('Icons', function()
        ---@diagnostic disable-next-line: undefined-field
        Snacks.picker.icons()
      end)

      util.user_cmd('Keys', function()
        Snacks.picker.keymaps()
      end)

      util.user_cmd('Manpage', function()
        Snacks.picker.man()
      end)

      util.user_cmd('Notifications', function()
        Snacks.notifier.show_history()
      end)

      util.user_cmd('Recent', function()
        Snacks.picker.recent()
      end)

      util.user_cmd('Term', function()
        Snacks.terminal.open()
      end)

      return {
        bigfile = {
          enabled = true,
        },
        dashboard = {
          preset = {
            header = [[                           _|
 _|_|      _|_|      _|_|    _|      _|        _|_|  _|_|
_|    _|  _|_|_|_|  _|    _|  _|      _|  _|  _|    _|    _|
_|    _|  _|        _|    _|    _|  _|    _|  _|    _|    _|
_|    _|    _|_|_|    _|_|        _|      _|  _|    _|    _|]],
            keys = {
              {
                icon = ' ',
                key = 'n',
                desc = 'New',
                action = ':ene',
              },
              {
                icon = ' ',
                key = 'f',
                desc = 'Find',
                action = function()
                  Snacks.dashboard.pick('smart')
                end,
              },
              {
                icon = ' ',
                key = 'e',
                desc = 'Explore',
                action = function()
                  Snacks.dashboard.pick('explorer')
                end,
              },
              {
                icon = ' ',
                key = 'g',
                desc = 'Grep',
                action = function()
                  Snacks.dashboard.pick('grep')
                end,
              },
              {
                icon = ' ',
                key = 'r',
                desc = 'Recent',
                action = function()
                  Snacks.dashboard.pick('recent')
                end,
              },
              {
                icon = ' ',
                key = 'm',
                desc = 'Modified',
                action = function()
                  Snacks.dashboard.pick('git_status')
                end,
              },
              {
                icon = ' ',
                key = 'c',
                desc = 'Config',
                action = function()
                  Snacks.dashboard.pick('files', {
                    dirs = { vim.fn.getenv('HOME') .. '/.config' },
                  })
                end,
              },
              {
                icon = '󰒲 ',
                key = 'l',
                desc = 'Lazy',
                action = ':Lazy',
                enabled = package.loaded.lazy ~= nil,
              },
              { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
            },
          },
        },
        indent = {
          enabled = true,
          indent = {
            only_scope = true,
            char = '┊',
          },
          animate = {
            enabled = true,
            duration = {
              step = 50, -- ms per step
              total = 1000, -- maximum duration
            },
          },
        },
        input = {
          enabled = true,
        },
        notifier = {
          enabled = true,
        },
        picker = {
          ui_select = true,
          layout = {
            preset = 'ivy',
            preview = false,
            layout = {
              height = 15,
            },
          },
          win = {
            input = {
              keys = {
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              },
            },
          },
          sources = {
            explorer = {
              auto_close = true,
              win = {
                input = {
                  keys = {
                    ['<Esc>'] = 'close',
                  },
                },
              },
              layout = {
                preset = 'ivy'
              }
            },
            files = {
              follow = true,
            },
            recent = {
              filter = {
                filter = function(item)
                  return item.file:find('COMMIT_EDITMSG') == nil
                end,
              },
            },
            lsp_symbols = {
              layout = {
                preview = true,
              },
            },
            undo = {
              layout = {
                preview = true,
              },
            },
          },
        },
        scope = {
          enabled = true,
        },
        statuscolumnn = {
          enabled = true,
          left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
        },
        words = {
          enabled = true,
        },
      }
    end,
  },
}
