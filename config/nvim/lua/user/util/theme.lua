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

-- return true if a color is "dark"
---@param color string
---@return boolean
function M.is_dark(color)
  local rgb = hex_to_rgb(color)
  local luminance = (0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3]) / 255
  return luminance < 0.5
end

return M
