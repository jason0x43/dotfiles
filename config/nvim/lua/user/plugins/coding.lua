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
      }
    end,
  },

  {
    'mfussenegger/nvim-lint',
    config = function()
      local lint = require('lint')

      lint.linters.tidy.ignore_exitcode = true
      lint.linters_by_ft.json = {}
      lint.linters_by_ft.text = {}
      lint.linters_by_ft.markdown = {}

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

  -- helpers for editing neovim lua; must be setup **before** any language
  -- servers are configured
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- bacon diagnostics
  {
    dir = '/Users/jason/.config/nvim/lua/bacon-diag',
    cond = vim.fn.findfile('.bacon-locations', '.;') ~= '',
    main = 'bacon-diag',
    config = true,
  },
}
