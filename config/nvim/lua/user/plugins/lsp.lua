return {
  -- Helpers for editing neovim lua; must be setup before lspconfig
  {
    'folke/neodev.nvim',

    -- ensure this loads before lsp
    priority = 100,

    config = function()
      require('neodev').setup({})
    end,
  },

  -- basic language server support
  'neovim/nvim-lspconfig',

  -- custom language servers
  {
    'jose-elias-alvarez/null-ls.nvim',

    dependencies = 'nvim-lua/plenary.nvim',

    config = function()
      local null_ls = require('null-ls')
      local helpers = require('null-ls.helpers')

      local htmlhint_source = {
        method = null_ls.methods.DIAGNOSTICS,
        filetypes = { 'html' },
        generator = helpers.generator_factory({
          command = 'htmlhint',
          args = { '--format', 'json', '--nocolor', 'stdin' },
          format = 'json',
          to_stdin = true,
          check_exit_code = { 0, 1 },
          on_output = function(params)
            if params.output == nil then
              return nil
            end

            local results = {}

            for _, err in ipairs(params.output) do
              for _, msg in ipairs(err.messages) do
                local severity
                if msg.type == 'error' then
                  severity = 1
                else
                  severity = 3
                end

                table.insert(results, {
                  row = msg.line,
                  col = msg.col,
                  end_col = msg.col + #msg.evidence,
                  message = msg.message .. ' (' .. msg.rule.id .. ')',
                  severity = severity,
                })
              end
            end

            return results
          end,
        }),
      }

      local tidy_xml_source = {
        name = 'tidy_xml',
        method = null_ls.methods.FORMATTING,
        filetypes = { 'xml', 'svg' },
        generator = helpers.formatter_factory({
          command = 'tidy',
          args = {
            '--tidy-mark',
            'no',
            '-quiet',
            '-indent',
            '--wrap',
            '80',
            '-xml',
            '--indent-attributes',
            'yes',
            '--indent-spaces',
            '2',
          },
          to_stdin = true,
        }),
      }

      -- run null_ls.config to make null-ls available through lspconfig
      local sources = {}

      if vim.fn.executable('black') ~= 0 then
        table.insert(sources, null_ls.builtins.formatting.black)
      end

      if vim.fn.executable('swiftformat') ~= 0 then
        table.insert(sources, null_ls.builtins.formatting.swiftformat)
      end

      if vim.fn.executable('prettier') ~= 0 then
        table.insert(
          sources,
          null_ls.builtins.formatting.prettier.with({
            filetypes = vim.list_extend(
              { 'php' },
              null_ls.builtins.formatting.prettier.filetypes
            ),
          })
        )
      end

      if vim.fn.executable('stylua') ~= 0 then
        table.insert(
          sources,
          null_ls.builtins.formatting.stylua.with({
            args = {
              '--stdin-filepath',
              '$FILENAME',
              '--search-parent-directories',
              '-',
            },
          })
        )
      end

      if vim.fn.executable('htmlhint') ~= 0 then
        table.insert(sources, htmlhint_source)
      end

      if vim.fn.executable('tidy') ~= 0 then
        table.insert(sources, tidy_xml_source)
      end

      null_ls.setup({
        sources = sources,
      })
    end,
  },

  -- language server installer
  {
    'williamboman/mason.nvim',
    config = function()
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

    config = function()
      require('mason-lspconfig').setup()
      require('user.lsp').config()

      -- use mason's automatic server startup functionality
      require('mason-lspconfig').setup_handlers({
        function(server_name)
          require('user.lsp').setup(server_name)
        end,
      })
    end,
  },
}