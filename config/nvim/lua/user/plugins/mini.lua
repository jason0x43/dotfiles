---mini.statusline LSPs section
---@param sl any
---@param args table
local function section_lsps(sl, args)
  local clients
  local client_names = {}

  if vim.lsp.get_clients ~= nil then
    clients = vim.lsp.get_clients()
  else
    clients = vim.lsp.get_active_clients()
  end

  for _, client in pairs(clients) do
    table.insert(client_names, client.name)
  end

  if vim.tbl_isempty(client_names) then
    return ''
  end

  local icon = ' '

  if sl.is_truncated(args.trunc_width) then
    client_names = vim.tbl_map(function(item)
      return item:sub(1, 2)
    end, client_names)
  end

  return string.format('%s%s', icon, table.concat(client_names, ','))
end

---hilight a string
---@param string string the string to highlight
---@param group string the highlight group to use
---@param resetGroup? string an optional highlight group to apply at the end
local function hl(string, group, resetGroup)
  local hlStr = string.format('%%%%#%s#%s', group, string)
  if resetGroup then
    hlStr = string.format('%s%%%%#%s#', hlStr, resetGroup)
  end
  return hlStr
end

---mini.statusline diagnostics section
---@param sl any
---@param args table
local function section_diagnostics(sl, args)
  local section = sl.section_diagnostics(args)
  section = string.gsub(section, '(E%d+)', hl('%1', 'MiniStatuslineError'))
  section = string.gsub(section, '(W%d+)', hl('%1', 'MiniStatuslineWarning'))
  section = string.gsub(section, '(I%d+)', hl('%1', 'MiniStatuslineInfo'))
  section = string.gsub(section, '(H%d+)', hl('%1', 'MiniStatuslineHint'))
  return section
end

local headers = {
  smkeyboard = {
    ' ____ ____ ____ ____ ____ ____ ',
    '||n |||e |||o |||v |||i |||m ||',
    '||__|||__|||__|||__|||__|||__||',
    '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
  },
  univers = {
    '                                               88',
    '                                               ""',
    '',
    '8b,dPPYba,   ,adPPYba,  ,adPPYba,  8b       d8 88 88,dPYba,,adPYba,',
    '88P\'   `"8a a8P_____88 a8"     "8a `8b     d8\' 88 88P\'   "88"    "8a',
    '88       88 8PP""""""" 8b       d8  `8b   d8\'  88 88      88      88',
    '88       88 "8b,   ,aa "8a,   ,a8"   `8b,d8\'   88 88      88      88',
    '88       88  `"Ybbd8"\'  `"YbbdP"\'      "8"     88 88      88      88',
  },
  starwars = {
    '.__   __.  _______   ______   ____    ____  __  .___  ___.',
    '|  \\ |  | |   ____| /  __  \\  \\   \\  /   / |  | |   \\/   |',
    '|   \\|  | |  |__   |  |  |  |  \\   \\/   /  |  | |  \\  /  |',
    '|  . `  | |   __|  |  |  |  |   \\      /   |  | |  |\\/|  |',
    "|  |\\   | |  |____ |  `--'  |    \\    /    |  | |  |  |  |",
    '|__| \\__| |_______| \\______/      \\__/     |__| |__|  |__|',
  },
  roman = {
    '                                             o8o',
    '                                             `"\'',
    'ooo. .oo.    .ooooo.   .ooooo.  oooo    ooo oooo  ooo. .oo.  .oo.',
    '`888P"Y88b  d88\' `88b d88\' `88b  `88.  .8\'  `888  `888P"Y88bP"Y88b',
    " 888   888  888ooo888 888   888   `88..8'    888   888   888   888",
    " 888   888  888    .o 888   888    `888'     888   888   888   888",
    "o888o o888o `Y8bod8P' `Y8bod8P'     `8'     o888o o888o o888o o888o",
  },
  epic = {
    ' _        _______  _______          _________ _______',
    '( (    /|(  ____ \\(  ___  )|\\     /|\\__   __/(       )',
    '|  \\  ( || (    \\/| (   ) || )   ( |   ) (   | () () |',
    '|   \\ | || (__    | |   | || |   | |   | |   | || || |',
    '| (\\ \\) ||  __)   | |   | |( (   ) )   | |   | |(_)| |',
    '| | \\   || (      | |   | | \\ \\_/ /    | |   | |   | |',
    '| )  \\  || (____/\\| (___) |  \\   /  ___) (___| )   ( |',
    '|/    )_)(_______/(_______)   \\_/   \\_______/|/     \\|',
  },
  block = {
    '                                          _|',
    '  _|_|      _|_|      _|_|    _|      _|        _|_|  _|_|',
    '_|    _|  _|_|_|_|  _|    _|  _|      _|  _|  _|    _|    _|',
    '_|    _|  _|        _|    _|    _|  _|    _|  _|    _|    _|',
    '_|    _|    _|_|_|    _|_|        _|      _|  _|    _|    _|',
  },
}

return {
  -- many things
  {
    'echasnovski/mini.nvim',

    version = false,

    config = function()
      -- file tree / explorer
      require('mini.files').setup({
        mappings = {
          go_in_plus = '<CR>',
        },
      })
      vim.keymap.set('n', '<leader>n', function()
        if vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1 then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        else
          MiniFiles.open()
        end
      end)

      -- pickers
      require('mini.extra').setup()
      require('mini.pick').setup()
      vim.ui.select = MiniPick.ui_select
      vim.keymap.set('n', '<leader>f', function()
        local in_worktree = require('user.util').in_git_dir()
        if in_worktree then
          MiniExtra.pickers.git_files()
        else
          MiniPick.builtin.files()
        end
      end)
      vim.keymap.set('n', '<leader>g', function()
        MiniPick.builtin.grep_live()
      end)
      vim.keymap.set('n', '<leader>e', function()
        MiniExtra.pickers.diagnostic({ scope = 'current' })
      end)
      vim.keymap.set('n', '<leader>b', function()
        MiniPick.builtin.buffers()
      end)
      vim.keymap.set('n', '<leader>h', function()
        MiniPick.builtin.help()
      end)
      vim.keymap.set('n', '<leader>m', function()
        MiniExtra.pickers.git_files({ scope = 'modified' })
      end)
      vim.keymap.set('n', '<leader>lr', function()
        MiniExtra.pickers.lsp({ scope = 'references' })
      end)
      vim.keymap.set('n', '<leader>vp', function()
        MiniExtra.pickers.visit_paths()
      end)
      vim.keymap.set('n', '<leader>vl', function()
        MiniExtra.pickers.visit_labels()
      end)

      -- buffer deletion
      require('mini.bufremove').setup()
      vim.keymap.set('n', '<leader>k', function()
        MiniBufremove.delete()
      end)
      vim.keymap.set('n', '<leader>K', function()
        MiniBufremove.wipeout()
      end)

      -- commenting
      require('mini.comment').setup()

      -- highlight current word
      require('mini.cursorword').setup()

      -- animated indent line
      require('mini.indentscope').setup()

      -- status line
      local sl = require('mini.statusline')
      sl.setup({
        content = {
          active = function()
            local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
            local git = sl.section_git({ trunc_width = 75 })
            local diagnostics = section_diagnostics(sl, { trunc_width = 75 })
            local filename = sl.section_filename({ trunc_width = 140 })
            local location = sl.section_location({ trunc_width = 140 })
            local lsps = section_lsps(sl, { trunc_width = 140 })

            return sl.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevInfo', strings = { git, diagnostics } },
              '%<', -- begin left alignment
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- end left alignment
              { hl = 'MiniStatuslineDevInfo', strings = { lsps } },
              { hl = mode_hl, strings = { location } },
            })
          end,
          inactive = function()
            local filename = sl.section_filename({})
            return sl.combine_groups({
              { hl = 'MiniStatuslineFilename', strings = { filename } },
            })
          end,
        },
      })

      -- start screen
      local starter = require('mini.starter')
      local height = vim.fn.winheight(0)
      local filter = function(lister)
        return function()
          return vim.tbl_filter(function(f)
            return f.name:find('COMMIT_EDITMSG') == nil
          end, lister())
        end
      end
      starter.setup({
        header = function()
          vim.keymap.set('n', '<ESC>', function()
            starter.close()
          end, { buffer = 0 })
          return table.concat(headers.block, '\n')
        end,
        footer = '',
        items = {
          filter(starter.sections.recent_files((height - 10) / 3, true)),
          filter(starter.sections.recent_files((height - 10) / 3, false)),
        },
      })

      -- surround
      require('mini.surround').setup()

      -- bracket movement
      require('mini.bracketed').setup()

      -- jumping around
      require('mini.jump2d').setup()

      -- notifications
      require('mini.notify').setup()
      vim.notify = require('mini.notify').make_notify()

      -- location and label tracking
      require('mini.visits').setup()
    end,
  },
}
