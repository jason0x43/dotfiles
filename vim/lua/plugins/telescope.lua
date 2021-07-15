local actions = require('telescope.actions')
local telescope = require('telescope')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = actions.close,
      },
    },
    layout_config = {
      prompt_position = 'top',
      preview_cutoff = 1,

      width = function(_, max_columns, _)
        return math.min(max_columns - 3, 80)
      end,

      height = function(_, _, max_lines)
        return math.min(max_lines - 4, 15)
      end,
    },
    layout_strategy = 'center',
    sorting_strategy = 'ascending',
    borderchars = {
      { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
      preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
  },
  pickers = {
    buffers = {
      previewer = false,
      results_title = false,
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
      previewer = false,
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
  },
})

telescope.load_extension('fzy_native')

util.keys.lmap('ff', ':lua require("telescope.builtin").find_files()<cr>')
util.keys.lmap('fb', ':lua require("telescope.builtin").file_browser()<cr>')
util.keys.lmap('fg', ':lua require("telescope.builtin").live_grep()<cr>')
util.keys.lmap('fr', ':lua require("telescope.builtin").oldfiles()<cr>')
util.keys.lmap('b', ':lua require("telescope.builtin").buffers()<cr>')
util.keys.lmap('g', ':lua require("telescope.builtin").git_files()<cr>')
util.keys.lmap('h', ':lua require("telescope.builtin").help_tags()<cr>')
util.keys.lmap('th', ':lua require("telescope.builtin").highlights()<cr>')
util.keys.lmap('lr', ':lua require("telescope.builtin").lsp_references()<cr>')
util.keys.lmap('ls', ':lua require("telescope.builtin").lsp_document_symbols()<cr>')
util.keys.lmap('la', ':lua require("telescope.builtin").lsp_code_actions()<cr>')
util.keys.lmap('ld', ':lua require("telescope.builtin").lsp_workspace_diagnostics()<cr>')
