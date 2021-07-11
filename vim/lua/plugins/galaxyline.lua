vim.cmd('packadd! galaxyline.nvim')
vim.cmd('packadd! nvim-web-devicons')

local gl = require('galaxyline')
local util = require('util')
local g = vim.g

local gl_inactive_galaxyline = gl.inactive_galaxyline
gl.inactive_galaxyline = function()
  vim.b.is_inactive = true
  print('setting to true')
  gl_inactive_galaxyline()
  print('setting to false')
  vim.b.is_inactive = false
end

local colors = {
  yellow = g.base16_gui0A,
  cyan = g.base16_gui0C,
  green = g.base16_gui0B,
  orange = g.base16_gui09,
  purple = g.base16_gui0E,
  magenta = g.base16_gui0F,
  grey = g.base16_gui02,
  blue = g.base16_gui0D,
  red = g.base16_gui08
}

local condition = require('galaxyline.condition')
local gls = gl.section
local append = table.insert

gl.short_line_list = { 'NvimTree' }

local mode_info = {
  [110] = { 'NORMAL', colors.blue },
  [105] = { 'INSERT', colors.green },
  [118] = { 'VISUAL', colors.purple },
  [22] = { 'V-BLOCK', colors.purple },
  [86] = { 'V-LINE', colors.purple },
  [99] = { 'COMMAND', colors.magenta },
  [116] = { 'TERMINAL', colors.blue },
  [115] = { 'SELECT', colors.orange },
  [83] = { 'S-LINE', colors.orange }
}

local get_mode_info = function()
  return mode_info[vim.fn.mode():byte()]
end

local space = function()
  return ' '
end

local filetype_name = function()
  return vim.bo.filetype
end

append(
  gls.left, {
    ViMode = {
      provider = function()
        -- auto change color according the vim mode
        local info = get_mode_info()
        util.hi('GalaxyViMode', { guibg = info[2], guifg = vim.g.base16_gui00 })
        return '  ' .. info[1] .. ' '
      end,
      separator_highlight = 'StatusLineSeparator'
    }
  }
)

append(
  gls.left, {
    GitBranch = {
      provider = 'GitBranch',
      icon = '   ',
      condition = condition.check_git_workspace,
      highlight = 'StatusLineMiddle',
      separator = ' ',
      separator_highlight = 'StatusLineMiddle'
    }
  }
)

-- append(
--   gls.left, {
--     DiffAdd = {
--       provider = 'DiffAdd',
--       condition = condition.hide_in_width,
--       icon = '  ',
--       highlight = 'StatusLineGitAdd'
--     }
--   }
-- )

-- append(
--   gls.left, {
--     DiffModified = {
--       provider = 'DiffModified',
--       condition = condition.hide_in_width,
--       icon = ' 柳',
--       highlight = 'StatusLineGitChange'
--     }
--   }
-- )

-- append(
--   gls.left, {
--     DiffRemove = {
--       provider = 'DiffRemove',
--       condition = condition.hide_in_width,
--       icon = '  ',
--       highlight = 'StatusLineGitDelete'
--     }
--   }
-- )

-- append(
--   gls.left, {
--     Filler = {
--       provider = function()
--         return ' '
--       end,
--       highlight = 'StatusLineGitDelete'
--     }
--   }
-- )

append(
  gls.left, {
    FileInfo = {
      provider = { space, 'FileIcon', 'FileName' },
      condition = function()
        local fname = vim.fn.expand('%:t')
        return vim.fn.empty(fname) ~= 1
      end,
      highlight = 'StatusLineFileInfo'
    }
  }
)

append(
  gls.left, {
    NoFile = {
      provider = function()
        return ' [No file]'
      end,
      condition = function()
        local fname = vim.fn.expand('%:t')
        return vim.fn.empty(fname) == 1
      end,
      highlight = 'StatusLineFileInfo'
    }
  }
)

append(
  gls.right, {
    DiagnosticError = {
      provider = 'DiagnosticError',
      icon = '  ',
      highlight = 'StatusLineLspDiagnosticsError'
    }
  }
)

append(
  gls.right, {
    DiagnosticWarn = {
      provider = 'DiagnosticWarn',
      icon = '  ',
      highlight = 'StatusLineLspDiagnosticsWarning'
    }
  }
)

append(
  gls.right, {
    DiagnosticInfo = {
      provider = 'DiagnosticInfo',
      icon = '  ',
      highlight = 'StatusLineLspDiagnosticsInformation'
    }
  }
)

append(
  gls.right, {
    DiagnosticHint = {
      provider = 'DiagnosticHint',
      icon = '  ',
      highlight = 'StatusLineLspDiagnosticsHint'
    }
  }
)

append(
  gls.right, {
    TreesitterIcon = {
      provider = function()
        return ' '
      end,
      condition = function()
        return next(vim.treesitter.highlighter.active) ~= nil
      end,
      separator = ' ',
      separator_highlight = 'StatusLineTreeSitter',
      highlight = 'StatusLineTreeSitter'
    }
  }
)

append(
  gls.right, {
    LspClients = {
      provider = function()
        local msg = '-'
        local buf_ft = vim.bo.filetype
        local clients = vim.lsp.get_active_clients()

        if not vim.tbl_isempty(clients) then
          local lsps = {}
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.tbl_contains(filetypes, buf_ft) then
              append(lsps, client.name)
            end
          end

          if #lsps > 0 then
            msg = table.concat(lsps, ',')
          end
        end

        return msg .. ' '
      end,
      condition = function()
        local tbl = { ['dashboard'] = true, [' '] = true }
        if tbl[vim.bo.filetype] then
          return false
        end
        return true
      end,
      icon = ' ',
      highlight = 'StatusLineInner',
      separator = '│ ',
      separator_highlight = 'StatusLineInnerSep'
    }
  }
)

append(
  gls.right, {
    Percent = {
      provider = 'LinePercent',
      icon = ' ',
      highlight = 'StatusLineMiddle'
    }
  }
)

append(
  gls.right, {
    LineInfo = {
      provider = 'LineColumn',
      highlight = 'GalaxyViMode',
      separator = ' ',
      separator_highlight = 'GalaxyViMode'
    }
  }
)

-- short/inactive line

append(
  gls.short_line_left, {
    BufferType = {
      provider = function()
        print('is inactive? ' .. vim.inspect(vim.b.is_inactive))
        if vim.b.is_inactive then
          return 'inactive'
        else
          return '[' .. filetype_name() .. ']'
        end
      end,
      highlight = function()
        if is_inactive then
          return 'StatusLineMiddle'
        else
          return 'StatusLineInner'
        end
      end,
      separator = ' ',
      separator_highlight = 'StatusLineInner'
    }
  }
)

append(
  gls.short_line_left, {
    SFileName = {
      provider = 'SFileName',
      condition = condition.buffer_not_empty,
      highlight = 'StatusLineInner'
    }
  }
)
