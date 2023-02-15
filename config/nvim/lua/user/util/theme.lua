local hex_pat = '[abcdef0-9][abcdef0-9]'
local pat = '^#(' .. hex_pat .. ')(' .. hex_pat .. ')(' .. hex_pat .. ')$'

local M = {}

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
function M.darken(hex, amount, bg)
  local status, val = pcall(blend, hex, bg or '#000000', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

-- lighten an rgb color
-- @param fg the base "light" color
function M.lighten(hex, amount, fg)
  local status, val = pcall(blend, hex, fg or '#ffffff', 1 - math.abs(amount))
  if status then
    return val
  end
  return hex
end

-- return true if a color is "dark"
function M.is_dark(color)
  local rgb = hex_to_rgb(color)
  local luminance = (0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3]) / 255
  return luminance < 0.5
end

-- shift a color by a percentage
-- the shift direction depends on whether the shift amount is positive or
-- negative and whether the current background is light or dark
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
local function get_color(hlgroup, attr)
  local col =
    vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hlgroup)), attr .. '#')
  if col == '' then
    return 'NONE'
  end
  return col
end

-- return a function for retrieving named colors
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
function M.update_theme()
  vim.cmd('colorscheme base16')
end

-- define a syntax highlight group
-- propsOrFg can either be a table containing guifg, guibg, etc., or a fg value.
-- If propsOrFg is a table, the remaining arguments will be ignored.
function M.hi(group, fg, bg, sp, modifiers)
  if type(group) ~= 'string' then
    error('Group must be a string' .. vim.inspect(group))
  end
  if fg and type(fg) ~= 'string' then
    error('fg must be a string' .. vim.inspect(fg))
  end
  if bg and type(bg) ~= 'string' then
    error('bg must be a string' .. vim.inspect(bg))
  end
  if sp and type(sp) ~= 'string' then
    error('sp must be a string: ' .. vim.inspect(sp))
  end
  if modifiers and type(modifiers) ~= 'table' then
    error('modifiers must be a table: ' .. vim.inspect(modifiers))
  end

  local opts = {
    fg = fg or '',
    bg = bg or '',
    sp = sp or '',
  }
  local mods = modifiers or {}

  if vim.tbl_contains(mods, 'underline') then
    opts.underline = true
  end
  if vim.tbl_contains(mods, 'bold') then
    opts.bold = true
  end
  if vim.tbl_contains(mods, 'undercurl') then
    opts.undercurl = true
  end

  vim.api.nvim_set_hl(0, group, opts)
end

-- link one syntax group to another
function M.hi_link(group1, group2)
  vim.api.nvim_set_hl(0, group1, { link = group2 })
end

return M
