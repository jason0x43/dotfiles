local hex_pat = '[abcdef0-9][abcdef0-9]'
local pat = '^#(' .. hex_pat .. ')(' .. hex_pat .. ')(' .. hex_pat .. ')$'

local M = {}

-- convert a hex color to split RGB values
---@param hex_str string
---@return number[]
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
---@param fg string
---@param bg string
---@param alpha number
---@return string
local function blend(fg, bg, alpha)
  local _bg = hex_to_rgb(bg)
  local _fg = hex_to_rgb(fg)

  local function blendChannel(i)
    local ret = (alpha * _fg[i] + ((1 - alpha) * _bg[i]))
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
---@param hex string
---@param amount number
---@param bg string? the base "dark" color
---@return string
function M.darken(hex, amount, bg)
  local status, val = pcall(blend, hex, bg or '#000000', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

-- lighten an rgb color
---@param hex string
---@param amount number
---@param fg string? the base "light" color
---@return string
function M.lighten(hex, amount, fg)
  local status, val = pcall(blend, hex, fg or '#ffffff', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

-- return true if a color is "dark"
---@param color string
---@return boolean
function M.is_dark(color)
  local rgb = hex_to_rgb(color)
  local luminance = (0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3]) / 255
  return luminance < 0.5
end

-- shift a color by a percentage
-- the shift direction depends on whether the shift amount is positive or
-- negative and whether the current background is light or dark
---@param hex string
---@param amount number
---@return string
function M.shift(hex, amount)
  local shifter
  if vim.go.background == 'dark' then
    if amount > 0 then
      shifter = M.darken
    else
      shifter = M.lighten
    end
  else
    if amount > 0 then
      shifter = M.lighten
    else
      shifter = M.darken
    end
  end
  return shifter(hex, amount)
end

-- get a color from a vim highlight group
---@param hlgroup string
---@param attr string
---@return string
local function get_color(hlgroup, attr)
  local col =
    vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hlgroup)), attr .. '#')
  if col == '' then
    return 'NONE'
  end
  return col
end

-- return a function for retrieving named colors
---@return function(name: string, shift_amt: number?): string
function M.get_colors()
  local semantic = {
    error = get_color('LspDiagnosticsDefaultError', 'fg'),
    warning = get_color('LspDiagnosticsDefaultWarning', 'fg'),
    hint = get_color('LspDiagnosticsDefaultHint', 'fg'),
    info = get_color('LspDiagnosticsDefaultInformation', 'fg'),
    bg = get_color('Search', 'fg'),
    bg_status = M.darken(get_color('LineNr', 'bg'), 0.025),
    fg = get_color('Normal', 'fg'),
    fg_status = get_color('Normal', 'bg'),
    bg_sign = get_color('SignColumn', 'bg'),
    fg_sign = get_color('SignColumn', 'fg'),
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

  local colors = vim.tbl_extend('force', semantic, named)

  ---@param name string
  ---@param shift_amt number?
  ---@return string
  return function(name, shift_amt)
    assert(colors[name] ~= nil, 'Accessed nil color "' .. name .. '"')
    local color = colors[name]
    if shift_amt ~= nil then
      return M.shift(color, shift_amt)
    end
    return color
  end
end

-- apply any theme customizations
---@return nil
function M.update_theme()
  vim.cmd('colorscheme base16')
end

return M
