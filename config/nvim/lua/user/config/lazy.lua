local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end

vim.opt.runtimepath:prepend(lazypath)

local util = require('user.util')
local defaults = require('lazy.core.config').defaults

require('lazy').setup(
  {
    -- native LSP
    {
      'neovim/nvim-lspconfig',
      config = function()
        -- Give LspInfo window a border
        require('lspconfig.ui.windows').default_options.border = 'rounded'
      end,
    },

    -- language server installer
    {
      'williamboman/mason.nvim',
      priority = 100,
      build = ':MasonUpdate',
      config = function()
        util.user_cmd('MasonUpgrade', function()
          require('user.util.mason').upgrade()
        end)
        require('mason').setup({
          ui = {
            border = 'rounded',
          },
        })
      end,
    },

    -- language server manager
    {
      'williamboman/mason-lspconfig.nvim',
      config = true,
    },

    -- mini
    {
      'echasnovski/mini.nvim',

      version = false,

      dependencies = { 'glepnir/nerdicons.nvim' },

      config = function()
        local mini_util = require('user.util.mini')

        -- status line
        local sl = require('mini.statusline')
        sl.setup({
          content = {
            active = function()
              local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
              local git = sl.section_git({ trunc_width = 75 })
              local diagnostics =
                mini_util.section_diagnostics(sl, { trunc_width = 75 })
              local filename = sl.section_filename({ trunc_width = 140 })
              local location = sl.section_location({ trunc_width = 140 })
              local lsps = mini_util.section_lsps(sl, { trunc_width = 140 })

              return sl.combine_groups({
                { hl = mode_hl, strings = { mode } },
                {
                  hl = 'MiniStatuslineDevInfo',
                  strings = { git, diagnostics },
                },
                '%<', -- begin left alignment
                { hl = 'MiniStatuslineFilename', strings = { filename } },
                '%=', -- end left alignment
                { hl = 'MiniStatuslineDevInfo', strings = { lsps } },
                { hl = mode_hl, strings = { location } },
              })
            end,
            inactive = function()
              local filename = sl.section_filename({})
              return sl.combine_groups({
                { hl = 'MiniStatuslineFilename', strings = { filename } },
              })
            end,
          },
        })

        -- surround
        require('mini.surround').setup()

        -- jumping around
        require('mini.jump2d').setup()

        -- diffing
        require('mini.diff').setup()
        vim.api.nvim_create_user_command('Diff', function()
          MiniDiff.toggle_overlay(0)
        end, {})

        -- icons
        require('mini.icons').setup()
        MiniIcons.mock_nvim_web_devicons()
      end,
    },

    -- snacks
    {
      'folke/snacks.nvim',
      priority = 1000,
      lazy = false,
      config = function()
        require('snacks').setup({
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
              ---@diagnostic disable-next-line: assign-type-mismatch
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
                  preset = 'ivy',
                },
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
                  ---@diagnostic disable-next-line: assign-type-mismatch
                  preview = true,
                },
              },
              undo = {
                layout = {
                  ---@diagnostic disable-next-line: assign-type-mismatch
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
        })

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
      end,
    },

    -- filetypes
    {
      'mustache/vim-mustache-handlebars',
      'jwalton512/vim-blade',
      'cfdrake/vim-pbxproj',
    },

    -- treesitter
    {
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup({
          auto_install = true,
          sync_install = true,
          ensure_installed = {},
          modules = {},
          ignore_install = {},
          highlight = {
            enable = true,
          },
          indent = {
            enable = true,
          },
          matchup = {
            enable = true,
          },
          context_commentstring = {
            enable = true,
          },
        })
      end,
    },

    -- helpers for editing neovim lua
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      config = function()
        require('lazydev').setup({
          enabled = true,
          debug = false,
          runtime = vim.env.VIMRUNTIME,
          integrations = {
            lspconfig = true,
          },
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        })
      end,
    },

    -- formatting
    {
      'stevearc/conform.nvim',
      config = function()
        util.user_cmd('Format', function()
          require('conform').format({ lsp_fallback = true })
        end)

        require('conform').setup({
          formatters_by_ft = {
            blade = { 'prettier' },
            css = { 'prettier' },
            fish = { 'fish_indent' },
            html = { 'prettier' },
            javascript = { 'prettier', 'deno_fmt' },
            javascriptreact = { 'prettier' },
            json = { 'prettier' },
            jsonc = { 'prettier' },
            lua = { 'stylua' },
            markdown = { 'prettier' },
            python = { 'ruff_format' },
            swift = { 'swift_format' },
            tex = { 'latexindent' },
            typescript = { 'prettier' },
            typescriptreact = { 'prettier' },
          },
          formatters = {
            prettier = {
              cwd = require('conform.util').root_file({
                'package.json',
                'jsconfig.json',
                'tsconfig.json',
              }),
              require_cwd = false,
            },
            deno_fmt = {
              cwd = require('conform.util').root_file({
                'deno.json',
              }),
              require_cwd = true,
            },
            latexindent = {
              prepend_args = { '-m' },
            },
          },
        })
      end,
    },

    -- copilot integration
    {
      'zbirenbaum/copilot.lua',
      enabled = function()
        return vim.fn.executable('node') == 1
      end,
      config = function()
        require('copilot').setup({
          event = 'InsertEnter',
          suggestion = {
            enabled = false,
            auto_trigger = true,
          },
          panel = { enabled = false },
          filetypes = {
            ['*'] = function()
              return vim.bo.filetype ~= 'bigfile'
            end,
          },
        })
      end,
    },

    -- highlight color strings
    {
      'norcalli/nvim-colorizer.lua',
      cond = vim.go.termguicolors,
      config = function()
        require('colorizer').setup({}, {
          names = false,
          rgb_fn = true,
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = '*',
          callback = function(ev)
            if ev.match == 'bigfile' then
              return
            end
            require('colorizer').attach_to_buffer(ev.buf)
          end,
        })
      end,
    },

    -- better start/end matching
    {
      'andymass/vim-matchup',
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      end,
    },

    -- JSON schemas
    'b0o/schemastore.nvim',

    -- better git diff views
    {
      'sindrets/diffview.nvim',
      cmd = 'DiffviewOpen',
      config = function()
        require('diffview').setup()
      end,
    },

    -- Git tools
    'tpope/vim-fugitive',

    -- Auto-set indentation
    {
      'tpope/vim-sleuth',
      config = function()
        -- Disable sleuth for markdown files as it slows the load time
        -- significantly
        vim.g.sleuth_markdown_heuristics = 0
      end,
    },

    -- bacon diagnostics
    {
      dir = '/Users/jason/.config/nvim/lua/bacon-diag',
      cond = vim.fn.findfile('.bacon-locations', '.;') ~= '',
      config = function()
        require('bacon-diag').setup()
      end,
    },

    -- completions
    {
      'saghen/blink.cmp',
      version = 'v0.*',
      dependencies = {
        'giuxtaposition/blink-cmp-copilot',
      },
      config = function()
        local providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            fallbacks = { 'lsp' },
          },
        }
        local default = { 'lsp', 'path', 'buffer', 'lazydev' }

        local ok, _ = pcall(require, 'copilot.api')
        if ok then
          providers.copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          }
          table.insert(default, 2, 'copilot')
        end

        require('blink.cmp').setup({
          sources = {
            default = default,
            cmdline = {},
            providers = providers,
          },
          signature = {
            enabled = true,
            window = {
              border = 'rounded',
            },
          },
          keymap = {
            preset = 'default',
            ['<C-e>'] = { 'select_and_accept' },
          },
        })
      end,
    },
  },
  vim.tbl_extend('force', defaults, {
    checker = {
      enabled = true,
      notify = false,
    },
    ui = {
      border = 'rounded',
    },
  })
)
