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

local defaults = require('lazy.core.config').defaults

-- Note: For improved type safety, avoid `opts` in favor of `config` to
-- configure plugins.

require('lazy').setup(
  {
    -- Native LSP configurations --------------------------------------
    {
      'neovim/nvim-lspconfig',
      config = function()
        -- Give LspInfo window a border
        require('lspconfig.ui.windows').default_options.border = 'rounded'
      end,
    },

    -- Language server and tool installer -----------------------------
    {
      'williamboman/mason.nvim',
      priority = 100,
      build = ':MasonUpdate',
      config = function()
        vim.api.nvim_create_user_command('MasonUpgrade', function()
          require('user.util.mason').upgrade()
        end, { desc = 'Upgrade Mason tools' })
        require('mason').setup({
          ui = {
            border = 'rounded',
          },
        })
      end,
    },

    -- Mason language server manager ----------------------------------
    {
      'williamboman/mason-lspconfig.nvim',
      config = function()
        require('mason-lspconfig').setup()
      end,
    },

    -- Mini -----------------------------------------------------------
    {
      'echasnovski/mini.nvim',
      config = function()
        local mini_util = require('user.util.mini')

        -- Git integration; used by statusline
        require('mini.git').setup()

        -- Modify how blame output is displayed
        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniGitCommandSplit',
          ---@param event MiniGitEvent
          callback = function(event)
            if event.data.git_subcommand ~= 'blame' then
              return
            end
            require('user.util.mini').show_git_blame(event.data)
          end,
        })

        vim.api.nvim_create_user_command(
          'Blame',
          'lefta vertical Git blame -c --date=relative %',
          {}
        )

        -- Diffing; used by status line
        require('mini.diff').setup()
        vim.api.nvim_create_user_command('Diff', function()
          MiniDiff.toggle_overlay(0)
        end, { desc = 'Toggle a git diff overlay' })

        -- Icons
        require('mini.icons').setup()
        MiniIcons.mock_nvim_web_devicons()

        -- Status line
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
        -- Don't show the mode on the last line since it's in the status line
        vim.o.showmode = false

        -- Surround
        require('mini.surround').setup()

        -- Jumping around
        require('mini.jump2d').setup()
      end,
    },

    -- Snacks ---------------------------------------------------------
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
                  key = 'b',
                  desc = 'Browse',
                  action = function()
                    Snacks.dashboard.pick('explorer')
                  end,
                },
                {
                  icon = '󰐰',
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
                    Snacks.dashboard.pick('recent', {
                      filter = {
                        cwd = true,
                      },
                    })
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
                    Snacks.dashboard.pick('explorer', {
                      cwd = vim.fn.getenv('HOME') .. '/.config',
                    })
                  end,
                },
                {
                  icon = '',
                  key = 'p',
                  desc = 'Packages',
                  action = ':Lazy',
                  enabled = package.loaded.lazy ~= nil,
                },
                {
                  icon = '',
                  key = 't',
                  desc = 'Tools',
                  action = ':Mason',
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
          image = {},
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
                follow = true,
              },
              files = {
                follow = true,
              },
              recent = {
                filter = {
                  filter = function(item)
                    return item.file:find('COMMIT_EDITMSG') == nil
                  end,
                  paths = {
                    -- override the default filter
                    [vim.fn.stdpath('data')] = true,
                  },
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
          styles = {
            ---@diagnostic disable-next-line: missing-fields
            dashboard = {
              wo = {
                fillchars = 'eob: ',
              },
            },
          },
          words = {
            enabled = true,
          },
        })

        vim.api.nvim_create_user_command('Commands', function()
          Snacks.picker.commands()
        end, { desc = 'List configured user commands' })

        vim.api.nvim_create_user_command('Config', function()
          Snacks.picker.explorer({ cwd = '~/.config' })
        end, { desc = 'Open an explorer in the config directory' })

        vim.api.nvim_create_user_command('Highlights', function()
          Snacks.picker.highlights()
        end, { desc = 'List highlight groups' })

        vim.api.nvim_create_user_command('Icons', function()
          Snacks.picker.icons()
        end, { desc = 'List available icons' })

        vim.api.nvim_create_user_command('Keys', function()
          Snacks.picker.keymaps()
        end, { desc = 'List configured keymaps' })

        vim.api.nvim_create_user_command('Notifications', function()
          Snacks.notifier.show_history()
        end, { desc = 'Show a list of displayed notifications' })

        vim.api.nvim_create_user_command('Recent', function()
          Snacks.picker.recent()
        end, { desc = 'Find recent files' })

        vim.api.nvim_create_user_command('Term', function()
          Snacks.terminal.open()
        end, { desc = 'Open a terminal' })

        vim.api.nvim_create_user_command('Dashboard', function()
          Snacks.dashboard.open()
        end, { desc = 'Open the startup screen' })

        vim.api.nvim_create_user_command('Help', function()
          Snacks.picker.help()
        end, { desc = 'Search for help pages' })
      end,
    },

    -- Misc filetype support ------------------------------------------
    {
      'mustache/vim-mustache-handlebars',
      'jwalton512/vim-blade',
      'cfdrake/vim-pbxproj',
    },

    -- Treesitter -----------------------------------------------------
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
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

    -- Auto-configure lua-ls ------------------------------------------
    {
      'folke/lazydev.nvim',
      config = function()
        require('lazydev').setup({
          enabled = true,
          debug = false,
          runtime = vim.env.VIMRUNTIME,
          integrations = {
            lspconfig = true,
          },
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            {
              path = 'nvim-lspconfig/lua',
              words = { 'lspconfig', 'lsp' },
            },
            {
              path = vim.fn.stdpath('config') .. '/lua/user/types/wezterm',
              words = { 'wezterm' },
            },
          },
        })
      end,
    },

    -- Code formatting ------------------------------------------------
    {
      'stevearc/conform.nvim',
      config = function()
        vim.api.nvim_create_user_command('Format', function()
          require('conform').format({ lsp_fallback = true })
        end, { desc = 'Format the current file' })

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

    -- Copilot integration --------------------------------------------
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

    -- Highlight color strings ----------------------------------------
    {
      'norcalli/nvim-colorizer.lua',
      cond = vim.go.termguicolors,
      config = function()
        require('colorizer').setup({ '!bigfile', '*' }, {
          names = false,
          rgb_fn = true,
        })
      end,
    },

    -- Better start/end matching --------------------------------------
    {
      'andymass/vim-matchup',
      config = function()
        vim.g.matchup_matchparen_offscreen =
          { method = 'popup', border = 'rounded' }
      end,
    },

    -- JSON schemas ---------------------------------------------------
    'b0o/schemastore.nvim',

    -- Better git diff views ------------------------------------------
    {
      'sindrets/diffview.nvim',
      cmd = 'DiffviewOpen',
      config = function()
        require('diffview').setup()
      end,
    },

    -- Auto-set indentation -------------------------------------------
    {
      'tpope/vim-sleuth',
      config = function()
        -- Disable sleuth for markdown files as it slows the load time
        -- significantly
        vim.g.sleuth_markdown_heuristics = 0
      end,
    },

    -- Bacon diagnostics ----------------------------------------------
    {
      dir = '/Users/jason/.config/nvim/lua/bacon-diag',
      cond = vim.fn.findfile('.bacon-locations', '.;') ~= '',
      config = function()
        require('bacon-diag').setup()
      end,
    },

    -- Completions ----------------------------------------------------
    {
      'saghen/blink.cmp',
      version = 'v0.*',
      dependencies = {
        -- Copilot provider
        'giuxtaposition/blink-cmp-copilot',
        -- Colorize menu items
        'xzbdmw/colorful-menu.nvim',
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

        -- Only add the copilot provider if copilot is active
        local ok, _ = pcall(require, 'copilot.api')
        if ok then
          -- Add a copilot kind to blink's list of completion kinds
          local CompletionItemKind =
            require('blink.cmp.types').CompletionItemKind
          local copilot_kind = #CompletionItemKind + 1
          CompletionItemKind[copilot_kind] = 'Copilot'

          providers.copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              return vim.tbl_map(function(item)
                item.kind = copilot_kind
                return item
              end, items)
            end,
          }
          table.insert(default, 2, 'copilot')
        end

        require('blink.cmp').setup({
          appearance = {
            -- Add a copilot icon to the default set
            kind_icons = vim.tbl_extend(
              'force',
              require('blink.cmp.config.appearance').default.kind_icons,
              {
                Copilot = '',
              }
            ),
          },
          completion = {
            documentation = {
              auto_show = true,
              window = {
                border = 'rounded',
              },
            },
            ghost_text = {
              enabled = true,
            },
            list = {
              selection = {
                preselect = false,
                auto_insert = false,
              },
            },
            menu = {
              draw = {
                columns = { { 'kind_icon' }, { 'label', gap = 1 } },
                components = {
                  label = {
                    text = function(ctx)
                      return require('colorful-menu').blink_components_text(ctx)
                    end,
                    highlight = function(ctx)
                      return require('colorful-menu').blink_components_highlight(
                        ctx
                      )
                    end,
                  },
                },
              },
            },
          },
          keymap = {
            preset = 'default',
            ['<C-e>'] = { 'select_and_accept' },
          },
          signature = {
            enabled = false,
            window = {
              border = 'rounded',
            },
          },
          sources = {
            default = default,
            cmdline = {},
            providers = providers,
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
