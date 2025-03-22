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

        vim.api.nvim_create_user_command('Blame', function()
          vim.cmd('lefta vertical Git blame -c --date=relative %')
        end, { desc = 'Show git blame info for the current file' })

        -- Diffing; used by status line
        require('mini.diff').setup()
        vim.api.nvim_create_user_command('Diff', function()
          MiniDiff.toggle_overlay(0)
        end, { desc = 'Toggle a git diff overlay' })

        -- Icons
        local icons = require('mini.icons')
        icons.setup()
        icons.mock_nvim_web_devicons()

        -- Current file map
        local mini_map = require('mini.map')
        mini_map.setup({
          integrations = {
            mini_map.gen_integration.diagnostic(),
            mini_map.gen_integration.builtin_search(),
          },
          symbols = {
            encode = mini_map.gen_encode_symbols.dot('3x2'),
          },
          window = {
            winblend = 0,
          },
        })

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
                  icon = ' ',
                  key = 'r',
                  desc = 'Recent',
                  action = function()
                    Snacks.dashboard.pick('recent', {
                      filter = {
                        cwd = vim.fn.getcwd(),
                      },
                    })
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
                  icon = '󰐰',
                  key = 'g',
                  desc = 'Grep',
                  action = function()
                    Snacks.dashboard.pick('grep')
                  end,
                },
                {
                  icon = ' ',
                  key = 'c',
                  desc = 'Config',
                  action = function()
                    Snacks.dashboard.pick('explorer', {
                      cwd = vim.uv.os_homedir() .. '/.config',
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
          image = {
            enabled = true,
          },
          indent = {
            enabled = true,
            animate = {
              enabled = true,
              duration = {
                step = 50, -- ms per step
                total = 1000, -- maximum duration
              },
            },
            indent = {
              only_scope = true,
              char = '┊',
            },
            scope = {
              enabled = false,
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
              autocmds = {
                -- Modify the default autocmd display to show the desc field
                format = function(item)
                  local format = require('snacks.picker.format').autocmd
                  local formatted = format(item)

                  ---@type vim.api.keyset.get_autocmds.ret
                  local au = item.item
                  if au.desc and formatted[#formatted][1] == 'callback' then
                    formatted[#formatted] = { au.desc, 'SnacksPickerDesc' }
                  end

                  return formatted
                end,
              },
              explorer = {
                win = {
                  input = {
                    keys = {
                      ['<Esc>'] = 'close',
                    },
                  },
                },
                layout = {
                  layout = {
                    position = 'right',
                  },
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
          quickfile = {},
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

        -- Update the recent source because it's not possible to remove items
        -- from the the default path filter
        require('snacks.picker.config.sources').recent.filter.paths = {
          [vim.fn.stdpath('cache')] = false,
          [vim.fn.stdpath('state')] = false,
        }

        -- When hitting enter on a file in explorer during a search, immediately
        -- jump to the file instead of updating the explorer view
        local explorer_actions = require('snacks.explorer.actions')
        local explorer_confirm = explorer_actions.actions.confirm
        explorer_actions.actions.confirm = function(picker, item, action)
          if item and not item.dir then
            Snacks.picker.actions.jump(picker, item, action)
          else
            explorer_confirm(picker, item, action)
          end
        end
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
          require('conform').format({ lsp_fallback = true, async = true })
        end, { desc = 'Format the current file' })

        require('conform').setup({
          formatters_by_ft = {
            blade = { 'prettier' },
            cs = { 'csharpier' },
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
        local last_status = vim.o.laststatus
        local actions = require('diffview.actions')
        local close_map = {
          'n',
          'q',
          actions.close,
          { desc = 'Close the diffview' },
        }
        require('diffview').setup({
          file_panel = {
            listing_style = 'list',
          },
          hooks = {
            view_opened = function()
              last_status = vim.o.laststatus
              vim.o.laststatus = 3
            end,
            view_closed = function()
              vim.o.laststatus = last_status
            end,
          },
          keymaps = {
            file_panel = {
              close_map,
              {
                'n',
                '<cr>',
                actions.focus_entry,
                { desc = 'Open the diff for the selected entry' },
              },
            },
            view = {
              close_map,
            },
          },
        })
        require('user.util.diffview').patch_layout()
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

    -- Messages -------------------------------------------------------
    {
      'AckslD/messages.nvim',
      config = function()
        require('messages').setup({
          prepare_buffer = function(opts)
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_set_option_value('filetype', 'messages', { buf = buf })
            local win = vim.api.nvim_open_win(buf, true, opts)
            vim.api.nvim_set_option_value('wrap', true, { win = win })
            return win
          end,
        })
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
          cmdline = {
            enabled = false,
          },
          completion = {
            accept = {
              auto_brackets = {
                enabled = false,
              },
            },
            documentation = {
              auto_show = true,
              window = {
                border = 'rounded',
              },
            },
            ghost_text = {
              enabled = false,
            },
            list = {
              selection = {
                preselect = false,
                auto_insert = true,
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
            ['<C-e>'] = { 'select_and_accept', 'fallback' },
          },
          signature = {
            enabled = false,
            window = {
              border = 'rounded',
            },
          },
          sources = {
            default = default,
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
