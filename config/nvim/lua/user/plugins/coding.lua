return {
  {
    'stevearc/conform.nvim',
    opts = function()
      vim.api.nvim_create_user_command('Format', function()
        require('conform').format({ lsp_fallback = true })
      end, {})

      vim.keymap.set('n', '<leader>F', function()
        require('conform').format({ lsp_fallback = true })
      end, {})

      return {
        formatters_by_ft = {
          css = { 'prettier' },
          lua = { 'stylua' },
          html = { 'prettier' },
          javascript = { 'prettier' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          markdown = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          swift = { 'swift_format' },
        },
      }
    end,
  },

  {
    'mfussenegger/nvim-lint',
    config = function()
      local lint = require('lint')

      lint.linters.tidy.ignore_exitcode = true
      lint.linters_by_ft.json = {}
      -- lint.linters_by_ft.text = {}
      -- lint.linters_by_ft.markdown = {}

      if vim.fn.executable('htmlhint') == 1 then
        lint.linters.htmlhint = {
          name = 'htmlhint',
          cmd = 'htmlhint',
          env = { ['NODE_OPTIONS'] = '--no-deprecation' },
          stdin = true,
          args = { 'stdin', '-f', 'compact' },
          stream = 'stdout',
          ignore_exitcode = true,
          parser = require('lint.parser').from_pattern(
            '.*: line (%d+), col (%d+), (%a+) %- (.+) %((.+)%)',
            { 'lnum', 'col', 'severity', 'message', 'code' },
            {
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
            },
            { source = 'htmlhint' }
          ),
        }

        lint.linters_by_ft.html = { 'htmlhint' }
      else
        lint.linters_by_ft.html = { 'tidy' }
      end

      vim.api.nvim_create_autocmd(
        { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
        {
          group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
          callback = function()
            require('lint').try_lint()
          end,
        }
      )

      vim.api.nvim_create_user_command('LintInfo', function()
        local runningLinters = table.concat(require('lint').get_running(), '\n')
        if runningLinters == '' then
          vim.notify(
            'No running linters',
            vim.log.levels.INFO,
            { title = 'nvim-lint' }
          )
        else
          vim.notify(
            runningLinters,
            vim.log.levels.INFO,
            { title = 'nvim-lint' }
          )
        end
      end, {})
    end,
  },
}
