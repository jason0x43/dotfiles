local util = require('util')
local hex_pat = '[abcdef0-9][abcdef0-9]'
local pat = '^#(' .. hex_pat .. ')(' .. hex_pat .. ')(' .. hex_pat .. ')$'

local exports = {}

-- convert a hex color to split RGB values
local function hex_to_rgb(hex_str)
  hex_str = string.lower(hex_str)

  assert(
    string.find(hex_str, pat) ~= nil,
    'hex_to_rgb: invalid hex_str: ' .. tostring(hex_str)
  )

  local r, g, b = string.match(hex_str, pat)
  return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

-- blend two colors
local function blend(fg, bg, alpha)
  bg = hex_to_rgb(bg)
  fg = hex_to_rgb(fg)

  local function blendChannel(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format(
    '#%02X%02X%02X',
    blendChannel(1),
    blendChannel(2),
    blendChannel(3)
  )
end

-- lighten an rgb color
-- @param bg the base "dark" color
function exports.darken(hex, amount, bg)
  return blend(hex, bg or '#000000', 1 - math.abs(amount))
end

-- lighten an rgb color
-- @param fg the base "light" color
function exports.lighten(hex, amount, fg)
  return blend(hex, fg or '#ffffff', 1 - math.abs(amount))
end

-- shift a color by a percentage
-- the shift direction depends on whether the shift amount is positive or
-- negative and whether the current background is light or dark
function exports.shift(hex, amount)
  local shifter
  if vim.go.background == 'dark' then
    if amount > 0 then
      shifter = exports.darken
    else
      shifter = exports.lighten
    end
  else
    if amount > 0 then
      shifter = exports.lighten
    else
      shifter = exports.darken
    end
  end
  return shifter(hex, amount)
end

-- get a color from a vim highlight group
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
    bg = get_color('Search', 'fg'),
    bg_status = exports.darken(get_color('LineNr', 'bg'), 0.025),
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

  return function(name, shift_amt)
    assert(colors[name] ~= nil, 'Accessed nil color "' .. name .. '"')
    local color = colors[name]
    if shift_amt ~= nil then
      return exports.shift(color, shift_amt)
    end
    return color
  end
end

-- apply any theme customizations
function exports.update_theme()
  vim.cmd('colorscheme base16')
end

return exports
