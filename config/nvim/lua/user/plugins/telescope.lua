local M = {}

M.config = function()
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
      borderchars = {
        -- no border, just separators
        -- prompt = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        -- results = { '─', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        -- preview = { ' ', ' ', '─', ' ', ' ', ' ', ' ', ' ' },

        -- single border
        { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
        results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
        preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      },
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
    },
  })

  telescope.load_extension('fzf')
  telescope.load_extension('zf-native')
  telescope.load_extension('file_browser')
  telescope.load_extension('ui-select')

  local lmap = require('user.util').lmap
  lmap('e', '<cmd>Telescope diagnostics bufnr=0<cr>')
  lmap('f', '<cmd>Telescope find_files<cr>')
  lmap('j', '<cmd>Telescope jumplist<cr>')
  lmap('s', '<cmd>Telescope current_buffer_fuzzy_find<cr>')
  lmap('g', '', {
    mode = 'n',
    callback = function()
      local opts = {}
      local builtin = require('telescope.builtin')
      local in_worktree = require('user.util').in_git_dir()
      if in_worktree then
        builtin.git_files(opts)
      else
        builtin.find_files(opts)
      end
    end,
  })
  lmap('b', '<cmd>Telescope buffers<cr>')
  lmap('tg', '<cmd>Telescope live_grep<cr>')
  lmap('th', '<cmd>Telescope help_tags<cr>')
  lmap('ts', '<cmd>Telescope symbols<cr>')
  lmap('lr', '<cmd>Telescope lsp_references<cr>')
  lmap('ls', '<cmd>Telescope lsp_document_symbols<cr>')
  lmap('lw', '<cmd>Telescope diagnostics<cr>')
end

return M
