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

telescope.load_extension('fzy_native')
telescope.load_extension('frecency')

local keys = require('util').keys

-- "find" maps
keys.lmap('ff', ':lua require("telescope.builtin").find_files()<cr>')
keys.lmap(
  'fr',
  ':lua require("telescope").extensions.frecency.frecency({previewer = false })<cr>'
)
keys.lmap('fg', ':lua require("telescope.builtin").git_files()<cr>')
keys.lmap('fb', ':lua require("telescope.builtin").buffers()<cr>')
keys.lmap('fo', ':lua require("telescope.builtin").oldfiles()<cr>')
keys.lmap('fh', ':lua require("telescope.builtin").help_tags()<cr>')

-- "telescope" maps
keys.lmap('tb', ':lua require("telescope.builtin").file_browser()<cr>')
keys.lmap('tg', ':lua require("telescope.builtin").live_grep()<cr>')
keys.lmap('tc', ':lua require("telescope.builtin").git_commits()<cr>')
keys.lmap('tl', ':lua require("telescope.builtin").highlights()<cr>')
keys.lmap('ts', ':lua require("telescope.builtin").symbols()<cr>')

-- "lsp" maps
keys.lmap('lr', ':lua require("telescope.builtin").lsp_references()<cr>')
keys.lmap('ls', ':lua require("telescope.builtin").lsp_document_symbols()<cr>')
keys.lmap('la', ':lua require("telescope.builtin").lsp_code_actions()<cr>')
keys.lmap(
  'ld',
  ':lua require("telescope.builtin").lsp_workspace_diagnostics()<cr>'
)

-- allow symbol access in insert mode
keys.imap('<C-e>', '<C-o>:lua require("telescope.builtin").symbols()<cr>')
