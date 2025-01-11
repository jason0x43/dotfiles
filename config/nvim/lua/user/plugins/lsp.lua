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

  -- language server installer; must be setup before null-ls to ensure
  -- mason-managed tools are available in the path
  {
    'williamboman/mason.nvim',
    priority = 100,
    build = ':MasonUpdate',
    opts = function()
      vim.api.nvim_create_user_command('MasonUpgrade', function()
        local to_check = 0
        local updating = 0

        local function check_done()
          if updating == 0 and to_check == 0 then
            io.write('Finished updating\n')

            vim.schedule(function()
              vim.api.nvim_exec_autocmds('User', {
                pattern = 'MasonUpgradeComplete',
              })
            end)
          end
        end

        io.write('Checking for updates...\n')

        local registry = require('mason-registry')

        -- This is blocking when called without a callback
        registry.refresh()
        io.write('Refreshed registry\n')

        registry.update(function(success, error)
          if not success then
            io.write('Error updating registry: ' .. error)
            vim.schedule(function()
              vim.api.nvim_exec_autocmds('User', {
                pattern = 'MasonUpgradeComplete',
              })
            end)

            return
          else
            io.write('Updated registry\n')
          end

          local packages = registry.get_installed_packages()
          to_check = #packages

          io.write('Checking ' .. to_check .. ' packages...\n')

          if to_check == 0 then
            check_done()
          else
            for _, pkg in ipairs(packages) do
              updating = updating + 1
              to_check = to_check - 1

              pkg:check_new_version(function(new_available, version)
                if new_available then
                  pkg:on('install:success', function()
                    io.write(
                      ('Updated %s to %s\n'):format(
                        pkg.name,
                        version.latest_version
                      )
                    )
                    updating = updating - 1
                    check_done()
                  end)

                  pkg:on('install:failure', function()
                    io.write(('Error updating %s\n'):format(pkg.name))
                    updating = updating - 1
                    check_done()
                  end)

                  io.write(
                    ('Updating %s to %s...\n'):format(
                      pkg.name,
                      version.latest_version
                    )
                  )
                  pkg:install({ version = version.latest_version, force = true })
                else
                  updating = updating - 1
                  check_done()
                end
              end)
            end
          end
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
