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
        return math.min(max_lines - 4, math.floor(max_lines * 0.3))
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
  extensions = {
    frecency = {
      previewer = false,
    },
  },
})
