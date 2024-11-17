return {
  -- native LSP
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('user.lsp').config()
    end,
  },

  -- LSP settings manager; must be setup **before** any language servers are
  -- configured
  {
    'folke/neoconf.nvim',
    config = true,
    priority = 100,
  },

  -- helpers for editing neovim lua; must be setup **before** any language
  -- servers are configured
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {},
    },
  },

  -- language server installer; must be setup before null-ls to ensure
  -- mason-managed tools are available in the path
  {
    'williamboman/mason.nvim',
    priority = 100,
    build = ':MasonUpdate',
    opts = function()
      vim.api.nvim_create_user_command('MasonUpgrade', function(context)
        local function check_done(updating, any_update)
          if updating == 0 then
            if any_update then
              io.write('Finished updating\n')
            else
              io.write('Nothing to update\n')
            end

            vim.schedule(function()
              vim.api.nvim_exec_autocmds('User', {
                pattern = 'MasonUpgradeComplete',
              })
            end)
          end
        end

        local checking = 0
        local updating = 0
        local any_update = false

        io.write('Checking for updates...\n')

        local registry = require('mason-registry')
        registry.refresh()
        registry.update(function(success, error)
          if not success then
            io.write('Error updating registry: ' .. error)
            vim.schedule(function()
              vim.api.nvim_exec_autocmds('User', {
                pattern = 'MasonUpgradeComplete',
              })
            end)

            return
          end

          ---@param pkg Package
          ---@param version NewPackageVersion
          ---@param succeeded boolean
          local update_finished = function(pkg, version, succeeded)
            updating = updating - 1
            if succeeded then
              io.write(
                ('Updated %s to %s\n'):format(pkg.name, version.latest_version)
              )
            else
              io.write(('Error updating %s\n'):format(pkg.name))
            end
            check_done(updating, any_update)
          end

          local packages = registry.get_installed_packages()
          for _, pkg in ipairs(packages) do
            checking = checking + 1

            pkg:check_new_version(function(new_available, version)
              if new_available then
                io.write(
                  ('Updating %s to %s...\n'):format(
                    pkg.name,
                    version.latest_version
                  )
                )
                any_update = true
                updating = updating + 1
                pkg:on('install:success', function()
                  update_finished(pkg, version, true)
                end)
                pkg:on('install:failure', function()
                  update_finished(pkg, version, false)
                end)
                pkg:install({ version = version.latest_version, force = true })
              end

              checking = checking - 1

              if checking == 0 then
                check_done(updating, any_update)
              end
            end)
          end

          check_done(updating, any_update)
        end)
      end, { force = true })

      return {
        ui = {
          border = 'rounded',
        },
      }
    end,
  },

  -- language server manager
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup()
      require('user.lsp').config()

      -- use mason's automatic server startup functionality
      require('mason-lspconfig').setup_handlers({
        function(server_name)
          require('user.lsp').setup(server_name)
        end,
      })

      -- manually setup sourcekit
      if vim.fn.executable('sourcekit-lsp') ~= 0 then
        require('user.lsp').setup('sourcekit')
      end

      vim.keymap.set('n', '<leader>a', function()
        vim.lsp.buf.code_action()
      end)
    end,
  },

  -- diagnostics display
  {
    'folke/trouble.nvim',
    event = 'BufEnter',
    keys = {
      {
        '<leader>td',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>tD',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>ts',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>tl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>tL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>tQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    opts = {
      focus = true,
    },
  },

  -- virtual text diagnostics
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = true,
    enabled = false,
    opts = function()
      vim.diagnostic.config({
        virtual_text = false,
      })
      vim.keymap.set('n', '<leader>l', require('lsp_lines').toggle)
      return {}
    end,
  },

  -- copilot integration
  {
    'zbirenbaum/copilot.lua',
    enabled = function()
      return vim.fn.executable('node') == 1
    end,
    opts = {
      event = 'InsertEnter',
      suggestion = {
        enabled = false,
        auto_trigger = true,
      },
      panel = { enabled = false },
      filetypes = {
        ['*'] = function()
          return not require('user.util').is_large_file(0)
        end,
      },
    },
  },
}
