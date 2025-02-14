local hex_pat = '[abcdef0-9][abcdef0-9]'
local pat = '^#(' .. hex_pat .. ')(' .. hex_pat .. ')(' .. hex_pat .. ')$'

local M = {}

---Convert a hex color to split RGB values
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

---Blend two colors
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

---Darken an RGB color
---@param hex string
---@param amount number
---@param bg string? the base "dark" color
---@return string
M.darken = function(hex, amount, bg)
  local status, val = pcall(blend, hex, bg or '#000000', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

---Lighten an RGB color
---@param hex string
---@param amount number
---@param fg string? the base "light" color
---@return string
M.lighten = function(hex, amount, fg)
  local status, val = pcall(blend, hex, fg or '#ffffff', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

---Shift a color by a percentage
---The shift direction depends on whether the shift amount is positive or
---negative and whether the current background is light or dark
---@param hex string
---@param amount number
---@return string
M.shift = function(hex, amount)
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

---Return true if a color is "dark"
---@param color string
---@return boolean
M.is_dark = function(color)
  local rgb = hex_to_rgb(color)
  local luminance = (0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3]) / 255
  return luminance < 0.5
end

---Convert an HSL color to RGB
---H is 0..360, S is 0..1, L is 0..1
---@param hsl { h: integer, s: number, l: number }
local function hsl_to_rgb(hsl)
  local c = (1 - math.abs(2 * hsl.l - 1)) * hsl.s
  local h = hsl.h / 60
  local x = c * (1 - math.abs(h % 2 - 1))
  local r = 0
  local g = 0
  local b = 0
  if 0 <= h and h < 1 then
    r = c
    g = x
    b = 0
  elseif 1 <= h and h < 2 then
    r = x
    g = c
    b = 0
  elseif 2 <= h and h < 3 then
    r = 0
    g = c
    b = x
  elseif 3 <= h and h < 4 then
    r = 0
    g = x
    b = c
  elseif 4 <= h and h < 5 then
    r = x
    g = 0
    b = c
  else
    r = c
    g = 0
    b = x
  end

  local m = hsl.l - c / 2
  r = math.floor((r + m) * 255)
  g = math.floor((g + m) * 255)
  b = math.floor((b + m) * 255)

  return { r = r, g = g, b = b }
end

---Convert an HSL color to RGB
---H is 0..360, S is 0..1, L is 0..1
---@param rgb { r: integer, g: integer, b: integer }
local function rgb_to_hex(rgb)
  local r = string.format('%02x', rgb.r)
  local g = string.format('%02x', rgb.g)
  local b = string.format('%02x', rgb.b)
  return string.format('#%s%s%s', r, g, b)
end

---Return a semi-random RGB color
---@param background? 'light' | 'dark'
M.random_rgb = function(background)
  local h = math.random(0, 359)
  local s = math.random(50, 100) / 100
  local l_min = background == 'dark' and 50 or 20
  local l_max = background == 'light' and 50 or 100
  local l = math.random(l_min, l_max) / 100
  local hsl = { h = h, s = s, l = l }
  local rgb = hsl_to_rgb(hsl)
  return rgb_to_hex(rgb)
end

return M
