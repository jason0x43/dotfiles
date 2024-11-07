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
          fish = { 'fish_indent' },
          html = { 'prettier' },
          javascript = { 'prettier', 'deno_fmt' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          markdown = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          swift = { 'swift_format' },
        },
        formatters = {
          prettier = {
            cwd = require('conform.util').root_file({
              'package.json', 'jsconfig.json', 'tsconfig.json'
            }),
            require_cwd = true,
          },
          deno_fmt = {
            cwd = require('conform.util').root_file({
              'deno.json',
            }),
            require_cwd = true,
          },
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
        lint.linters_by_ft.html = { 'htmlhint' }
      else
        lint.linters_by_ft.html = { 'tidy' }
      end

      vim.api.nvim_create_autocmd(
        { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
        {
          group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
          callback = function()
            -- Don't run linters in JS projects, because those should have
            -- more specific tooling
            if require('lspconfig').util.root_pattern('package.json') then
              return
            end
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
