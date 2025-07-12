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
      'mason-org/mason.nvim',
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
      'mason-org/mason-lspconfig.nvim',
      config = function()
        require('mason-lspconfig').setup({
          automatic_enable = true,
          ensure_installed = {},
        })
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
          vim.cmd('lefta vertical Git blame -c --date=relative -- %:p')
        end, { desc = 'Show git blame info for the current file' })

        -- Start screen
        local starter = require('mini.starter')
        starter.setup({
          evaluate_single = true,
          items = {
            {
              {
                action = 'Pick explorer',
                name = 'Explorer',
                section = 'Pick',
              },
              {
                action = 'Pick files',
                name = 'Files',
                section = 'Pick',
              },
              {
                action = 'Pick grep_live',
                name = 'Grep',
                section = 'Pick',
              },
              {
                action = 'Pick oldfiles current_dir=true',
                name = 'Recent',
                section = 'Pick',
              },
              {
                action = 'Pick help',
                name = 'Help',
                section = 'Pick',
              },
            },
            {
              {
                name = 'New buffer',
                action = 'enew',
                section = 'Actions',
              },
              {
                name = 'Quit',
                action = 'qall',
                section = 'Actions',
              },
            },
          },
          header = '',
          footer = '',
        })

        -- Pickers
        require('mini.pick').setup()
        require('mini.extra').setup()

        vim.keymap.set('n', '<leader>b', function()
          MiniPick.builtin.buffers()
        end, { desc = 'Find buffers' })

        vim.keymap.set('n', '<leader>d', function()
          MiniExtra.pickers.diagnostic()
        end, { desc = 'List diagnostics' })

        vim.keymap.set('n', '<leader>f', function()
          MiniPick.builtin.files()
        end, { desc = 'Find files' })

        vim.keymap.set('n', '<leader>h', function()
          MiniPick.builtin.help()
        end, { desc = 'Find help' })

        vim.keymap.set('n', '<leader>r', function()
          MiniExtra.pickers.oldfiles({ current_dir = true })
        end, { desc = 'Find recent files' })

        -- Buffer removal
        require('mini.bufremove').setup()

        vim.keymap.set('n', '<leader>k', function()
          MiniBufremove.delete()
        end, { desc = 'Close the current buffer' })

        vim.keymap.set('n', '<leader>K', function()
          MiniBufremove.delete(0, true)
        end, { desc = 'Close the current buffer with prejudice' })

        -- File manager
        require('mini.files').setup({
          mappings = {
            go_in = 'L',
            go_in_plus = 'l',
            go_out = 'H',
            go_out_plus = 'h',
          },
        })

        vim.keymap.set('n', '<leader>e', function()
          MiniFiles.open()
        end, { desc = 'Open a file explorer' })

        -- Diffing; used by status line
        require('mini.diff').setup()
        vim.api.nvim_create_user_command('Diff', function()
          MiniDiff.toggle_overlay(0)
        end, { desc = 'Toggle a git diff overlay' })

        -- Icons
        local icons = require('mini.icons')
        icons.setup()
        icons.mock_nvim_web_devicons()

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

        -- Move text
        require('mini.move').setup()

        -- Notifications
        require('mini.notify').setup()

        -- Indent guides
        require('mini.indentscope').setup({
          symbol = '│',
        })
      end,
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

    -- Misc filetype support ------------------------------------------
    {
      'mustache/vim-mustache-handlebars',
      'jwalton512/vim-blade',
      'cfdrake/vim-pbxproj',
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
            csharpier = {
              command = 'csharpier',
              args = { 'format', '--write-stdout' },
            },
          },
        })

        vim.keymap.set('n', '<leader>F', function()
          require('conform').format({ lsp_fallback = true, async = true })
        end, { desc = 'Format the current file' })
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

    -- LLM coding support ---------------------------------------------
    {
      'olimorris/codecompanion.nvim',
      config = function()
        require('codecompanion').setup({
          adapters = {
            copilot = function()
              return require('codecompanion.adapters').extend('copilot', {
                -- Use a model that supports streaming output
                schema = { model = { default = 'gpt-4o-2024-11-20' } },
              })
            end,
          },
          display = {
            chat = {
              window = {
                opts = {
                  number = false,
                  concealcursor = 'n',
                  conceallevel = 2,
                },
              },
            },
          },
          strategies = {
            chat = {
              adapter = 'copilot',
              keymaps = {
                stop = {
                  modes = { n = '<C-c>' },
                },
              },
            },
            inline = {
              adapter = 'copilot',
            },
            cmd = {
              adapter = 'copilot',
            },
          },
        })

        require('user.util.spinner').init_code_companion()

        vim.keymap.set('n', '<leader>zz', '<cmd>CodeCompanionActions<cr>', {
          desc = 'Open the CodeCompanion actions menu',
        })

        vim.keymap.set('n', '<leader>zc', '<cmd>CodeCompanionChat Toggle<cr>', {
          desc = 'Chat with CodeCompanion',
        })

        vim.keymap.set('n', '<leader>zf', '<cmd>CodeCompanion /fix<cr>', {
          desc = 'Fix the selected code with CodeCompanion',
        })

        vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', {
          desc = 'Add the selection to a CodeCompanion chat',
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'codecompanion',
          callback = function()
            vim.keymap.set('n', 'q', '<cmd>CodeCompanionChat Toggle<cr>', {
              desc = 'Close the chat window',
              buffer = 0,
            })
          end,
          desc = 'Enhance CodeCompanion windows.',
        })
      end,
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'j-hui/fidget.nvim',
      },
    },

    -- Better markdown ------------------------------------------------
    {
      'MeanderingProgrammer/render-markdown.nvim',
      ft = { 'codecompanion' },
      config = function()
        require('render-markdown').setup({
          anti_conceal = { enabled = false },
          win_options = {
            conceallevel = {
              default = vim.o.conceallevel,
              rendered = 3,
            },
            concealcursor = {
              default = vim.o.concealcursor,
              rendered = 'n',
            },
          },
          completions = {
            blink = { enabled = true },
          },
        })
      end,
    },
    {
      'OXY2DEV/markview.nvim',
      enabled = false,
      lazy = false,
      opts = {
        preview = {
          filetypes = { 'markdown', 'codecompanion' },
          ignore_buftypes = {},
        },
      },
    },

    -- Highlight color strings ----------------------------------------
    {
      'norcalli/nvim-colorizer.lua',
      event = 'VeryLazy',
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

    -- Messages -------------------------------------------------------
    {
      'AckslD/messages.nvim',
      enabled = false,
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
      init = function()
        -- Prevent 'press enter' message
        vim.o.messagesopt = 'wait:500,history:500'
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

    -- Key mapping hints ----------------------------------------------
    {
      'folke/which-key.nvim',
      enabled = false,
      event = 'VeryLazy',
      opts = {},
      keys = {
        {
          '<leader>?',
          function()
            require('which-key').show({ global = false })
          end,
          desc = 'Buffer Local Keymaps (which-key)',
        },
      },
    },

    -- Use vim as kitty's scrollback handler --------------------------
    {
      'mikesmithgh/kitty-scrollback.nvim',
      cmd = {
        'KittyScrollbackGenerateKittens',
        'KittyScrollbackCheckHealth',
        'KittyScrollbackGenerateCommandLineEditing',
      },
      event = { 'User KittyScrollbackLaunch' },
      config = function()
        require('kitty-scrollback').setup()
      end,
    },

    -- Kitty config filetype ------------------------------------------
    {
      'fladson/vim-kitty',
      ft = 'kitty',
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
