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
function M.hi(group, propsOrFg, bg, attr, sp)
  if type(group) == 'table' then
    for k, v in pairs(group) do
      M.hi(k, v)
    end
  else
    local props_list = {}
    local props = {}

    if type(propsOrFg) == 'table' then
      props = propsOrFg
    else
      props = {
        guifg = propsOrFg,
        guibg = bg,
        gui = attr,
        cterm = attr,
        guisp = sp,
      }
    end

    for k, v in pairs(props) do
      -- replace an empty value with NONE
      local val = (v == '' or v == nil) and 'NONE' or v

      if k == 'sp' then
        k = 'guisp'
      elseif k == 'style' then
        k = 'gui'
      elseif k == 'fg' then
        k = 'guifg'
      elseif k == 'bg' then
        k = 'guibg'
      end

      -- if gui{fg,bg,sp} don't start with a '#', prepend it
      if
        (k:find('gui%a') or k:find('^fg') or k:find('^bg'))
        and v:sub(1, 1) ~= '#'
      then
        val = '#' .. val
      end

      table.insert(props_list, k .. '=' .. val)
    end

    if vim.tbl_isempty(props_list) then
      error('Empty props for highlight group ' .. group)
    end

    vim.cmd('hi ' .. group .. ' ' .. table.concat(props_list, ' '))
  end
end

-- link one syntax group to another
function M.hi_link(group1, group2)
  vim.cmd('hi! link ' .. group1 .. ' ' .. group2)
end

return M
