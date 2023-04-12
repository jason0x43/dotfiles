return {
  'ibhagwan/fzf-lua',

  dependencies = 'nvim-tree/nvim-web-devicons',

  opts = function()
    vim.keymap.set('n', '<leader>e', function()
      require('fzf-lua').diagnostics_document()
    end)
    vim.keymap.set('n', '<leader>j', function()
      require('fzf-lua').jumps()
    end)
    vim.keymap.set('n', '<leader>f', function()
      local in_worktree = require('user.util').in_git_dir()
      if in_worktree then
        require('fzf-lua').git_files()
      else
        require('fzf-lua').files()
      end
    end)
    vim.keymap.set('n', '<leader>g', function()
      require('fzf-lua').live_grep_glob({
        git_icons = false,
        file_icons = false,
      })
    end)
    vim.keymap.set('n', '<leader>b', function()
      require('fzf-lua').buffers()
    end)
    vim.keymap.set('n', '<leader>h', function()
      require('fzf-lua').help_tags()
    end)
    vim.keymap.set('n', '<leader>lr', function()
      require('fzf-lua').lsp_references()
    end)
    vim.keymap.set('n', '<leader>ls', function()
      require('fzf-lua').lsp_document_symbols()
    end)
    vim.keymap.set('n', '<leader>a', function()
      require('fzf-lua').lsp_code_actions()
    end)

    local actions = require('fzf-lua.actions')

    return {
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
          args = '--force-colorization',
        },
      },
    }
  end,
}
