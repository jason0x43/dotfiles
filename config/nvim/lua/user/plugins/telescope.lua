return {
  'nvim-telescope/telescope.nvim',

	enabled = false,

  dependencies = {
    'plenary.nvim',
    'nvim-web-devicons',
    'natecraddock/telescope-zf-native.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    {
      'nvim-telescope/telescope-symbols.nvim',
      dependencies = 'plenary.nvim',
    },
    {
      'nvim-telescope/telescope-file-browser.nvim',
      dependencies = 'plenary.nvim',
    },
    'nvim-telescope/telescope-live-grep-raw.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'debugloop/telescope-undo.nvim',
  },

  config = function()
    local telescope = require('telescope')
    local action_set = require('telescope.actions.set')

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ['<esc>'] = require('telescope.actions').close,
          },
        },
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
          preview_cutoff = 35,
          preview_height = 0.5,

          width = function(_, max_columns, _)
            return math.max(max_columns - 16, 80)
          end,

          height = function(_, _, max_lines)
            return math.max(max_lines - 6, 30)
          end,
        },
        sorting_strategy = 'ascending',
        path_display = { 'truncate' },
      },
      pickers = {
        buffers = {
          previewer = false,
          results_title = false,
          sort_mru = true,
        },
        find_files = {
          previewer = false,
          results_title = false,
          no_ignore = true,
          hidden = true,
        },
        git_files = {
          previewer = false,
          results_title = false,
          recurse_submodules = true,
        },
        help_tags = {
          results_title = false,
          previewer = false,
          mappings = {
            i = {
              ['<cr>'] = function(prompt_bufnr)
                action_set.select(prompt_bufnr, 'tab')
              end,
            },
          },
        },
        live_grep = {
          results_title = false,
        },
        oldfiles = {
          previewer = false,
        },
        lsp_workspace_diagnostics = {
          -- don't show hints
          severity_limit = vim.g.lsp_severity_limit,
        },
        lsp_references = {
          show_line = false,
        },
        jumplist = {
          show_line = false,
          preview_title = 'Preview',
        },
      },
      extensions = {
        file_browser = {
          previewer = false,
        },
        ['zf-native'] = {
          generic = {
            enable = false,
          },
        },
        fzf = {
          override_file_sorter = false,
        },
        undo = {
          use_delta = false,
        },
      },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('zf-native')
    telescope.load_extension('file_browser')
    telescope.load_extension('ui-select')
    telescope.load_extension('undo')

    vim.keymap.set('n', '<leader>e', '<cmd>Telescope diagnostics bufnr=0<cr>')
    vim.keymap.set('n', '<leader>f', '<cmd>Telescope find_files<cr>')
    vim.keymap.set('n', '<leader>j', '<cmd>Telescope jumplist<cr>')
    vim.keymap.set('n', '<leader>g', function()
      local opts = {}
      local builtin = require('telescope.builtin')
      local in_worktree = require('user.util').in_git_dir()
      if in_worktree then
        builtin.git_files(opts)
      else
        builtin.find_files(opts)
      end
    end)
    vim.keymap.set('n', '<leader>b', '<cmd>Telescope buffers<cr>')
    vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>')
    vim.keymap.set('n', '<leader>tg', '<cmd>Telescope live_grep<cr>')
    vim.keymap.set('n', '<leader>th', '<cmd>Telescope help_tags<cr>')
    vim.keymap.set('n', '<leader>ts', '<cmd>Telescope symbols<cr>')
    vim.keymap.set('n', '<leader>lr', '<cmd>Telescope lsp_references<cr>')
    vim.keymap.set('n', '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>')
    vim.keymap.set('n', '<leader>ld', '<cmd>Telescope diagnostics<cr>')
  end,
}
