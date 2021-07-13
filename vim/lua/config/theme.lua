local util = require('util')
local exports = {}

-- apply any theme customizations
function exports.update_theme()
  print('updating theme')
end

local function get_color(hlgroup, attr)
  local col = vim.fn.synIDattr(
    vim.fn.synIDtrans(vim.fn.hlID(hlgroup)),
    attr .. '#'
  )
  if col == '' then
    return 'NONE'
  end
  return col
end

-- return a function for retrieving named colors
function exports.get_colors()
  local semantic = {
    error = get_color('LspDiagnosticsDefaultError', 'fg'),
    warning = get_color('LspDiagnosticsDefaultWarning', 'fg'),
    hint = get_color('LspDiagnosticsDefaultHint', 'fg'),
    info = get_color('LspDiagnosticsDefaultInformation', 'fg'),
    bg = get_color('Visual', 'fg'),
    bg_status = get_color('LineNr', 'bg'),
    fg = get_color('Normal', 'fg'),
    fg_status = get_color('Normal', 'bg'),
    comment = get_color('Comment', 'fg'),
    selection = get_color('LineNr', 'bg'),
  }

  local named = {
    dark_gray = get_color('Visual', 'bg'),
    green = get_color('DiffAdd', 'fg'),
    blue = get_color('Question', 'fg'),
    purple = get_color('Keyword', 'fg'),
    red = semantic.error,
  }

  local colors = util.assign(semantic, named)

  return function(name)
    assert(colors[name] ~= nil, 'Accessed nil color "' .. name .. '"')
    return colors[name]
  end
end

-- provide an externally callable command that can be used to dynamically
-- update the scheme in running neovim sessions
util.cmd('UpdateColors', 'lua theme.update_theme()')

_G.theme = exports
return exports
