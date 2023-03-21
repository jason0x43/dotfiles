return {
  'ibhagwan/fzf-lua',

  dependencies = {
    'nvim-web-devicons',
  },

  config = function()
    local actions = require('fzf-lua.actions')

    require('fzf-lua').setup({
      'fzf-native',

      fzf_opts = {
        ['--info'] = 'hidden',
      },

      winopts = {
        width = 0.85,
        preview = {
          layout = 'vertical',
          border = 'border-top',
        },
      },

      buffers = {
        no_header = true,
      },

      helptags = {
        actions = {
          ['default'] = actions.help_tab,
        },
      },

      manpages = {
        actions = {
          ['default'] = actions.man_tab,
        },
      },

      grep = {
        rg_opts = '--column --line-number --no-heading --color=always '
          .. '--hidden --smart-case --max-columns=4096',
        no_header = true,
      },

      previewers = {
        bat = {
          cmd = 'bat',
          -- delete all args so it uses external config
          args = '',
        },
      },
    })

    vim.keymap.set('n', '<leader>e', '<cmd>FzfLua diagnostics_document<cr>')
    vim.keymap.set('n', '<leader>f', '<cmd>FzfLua files<cr>')
    vim.keymap.set('n', '<leader>j', '<cmd>FzfLua jumps<cr>')
    vim.keymap.set('n', '<leader>g', function()
      local in_worktree = require('user.util').in_git_dir()
      if in_worktree then
        require('fzf-lua').git_files()
      else
        require('fzf-lua').files()
      end
    end)
    vim.keymap.set('n', '<leader>b', '<cmd>FzfLua buffers<cr>')
    vim.keymap.set('n', '<leader>tg', '<cmd>FzfLua live_grep_native<cr>')
    vim.keymap.set('n', '<leader>th', '<cmd>FzfLua help_tags<cr>')
    vim.keymap.set('n', '<leader>lr', '<cmd>FzfLua lsp_references<cr>')
    vim.keymap.set('n', '<leader>ls', '<cmd>FzfLua lsp_document_symbols<cr>')
    vim.keymap.set('n', '<leader>ld', '<cmd>FzfLua diagnostics_document<cr>')
    vim.keymap.set('n', '<leader>a', '<cmd>FzfLua lsp_code_actions<cr>')
  end,
}
