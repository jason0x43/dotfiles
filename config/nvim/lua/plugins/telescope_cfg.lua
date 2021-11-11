local telescope = require('req')('telescope')
if not telescope then
  return
end

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
      preview_height = 10,

      width = function(_, max_columns, _)
        return math.min(max_columns - 3, 80)
      end,

      height = function(_, _, max_lines)
        return math.min(max_lines - 2, 30)
      end,
    },
    sorting_strategy = 'ascending',
    borderchars = {
      prompt = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      results = { '─', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      preview = { ' ', ' ', '─', ' ', ' ', ' ', ' ', ' ' },
      -- { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      -- prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
      -- results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
      -- preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
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
    },
    git_files = {
      previewer = false,
      results_title = false,
    },
    help_tags = {
      results_title = false,
    },
    live_grep = {
      results_title = false,
    },
    oldfiles = {
      previewer = false,
    },
    file_browser = {
      previewer = false,
    },
    lsp_workspace_diagnostics = {
      -- don't show hints
      severity_limit = vim.g.lsp_severity_limit,
    },
  },
})

local lmap = require('util').lmap
lmap('f', '<cmd>Telescope find_files<cr>')
lmap('s', '<cmd>Telescope current_buffer_fuzzy_find<cr>')
lmap('g', '<cmd>Telescope git_files<cr>')
lmap('b', '<cmd>Telescope buffers<cr>')
lmap('tg', '<cmd>Telescope live_grep<cr>')
lmap('th', '<cmd>Telescope help_tags<cr>')
lmap('tl', '<cmd>Telescope highlights<cr>')
lmap('ts', '<cmd>Telescope symbols<cr>')
lmap('lr', '<cmd>Telescope lsp_references<cr>')
lmap('ls', '<cmd>Telescope lsp_document_symbols<cr>')
lmap('la', '<cmd>Telescope lsp_code_actions<cr>')
lmap('ld', '<cmd>Telescope lsp_document_diagnostics<cr>')
lmap('lw', '<cmd>Telescope lsp_workspace_diagnostics<cr>')
lmap('lw', '<cmd>Telescope lsp_workspace_diagnostics<cr>')
