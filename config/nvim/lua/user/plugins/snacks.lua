return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      words = { enabled = true },
      notifier = { enabled = true },
      dashboard = {
        preset = {
          header = [[                           _|
 _|_|      _|_|      _|_|    _|      _|        _|_|  _|_|
_|    _|  _|_|_|_|  _|    _|  _|      _|  _|  _|    _|    _|
_|    _|  _|        _|    _|    _|  _|    _|  _|    _|    _|
_|    _|    _|_|_|    _|_|        _|      _|  _|    _|    _|]],
          pick = function(cmd, opts)
            if cmd == 'oldfiles' then
              return MiniExtra.pickers.oldfiles(opts)
            end

            if cmd == 'modified' then
              local o = opts or {}
              o.scope = 'modified'
              return MiniExtra.pickers.git_files(o)
            end

            if cmd == 'config' then
              return MiniPick.builtin.files({}, {
                source = { cwd = vim.fn.stdpath('config') },
              })
            end

            return require('mini.pick').builtin[cmd](opts)
          end,
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
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = ' ',
              key = 'b',
              desc = 'Browse',
              action = ":lua MiniFiles.open()",
            },
            {
              icon = ' ',
              key = 'g',
              desc = 'Grep',
              action = ":lua Snacks.dashboard.pick('grep_live')",
            },
            {
              icon = ' ',
              key = 'r',
              desc = 'Recent',
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = ' ',
              key = 'm',
              desc = 'Modified',
              action = ":lua Snacks.dashboard.pick('modified')",
            },
            {
              icon = ' ',
              key = 'c',
              desc = 'Config',
              action = ":lua Snacks.dashboard.pick('config')",
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
    },
  },
}
