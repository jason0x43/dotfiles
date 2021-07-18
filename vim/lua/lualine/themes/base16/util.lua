local exports = {}

-- return a theme using colors from the active colorscheme
function exports.get_theme()
  local c = require('config.theme').get_colors()
  return {
    normal = {
      a = { fg = c('bg'), bg = c('blue'), gui = 'bold' },
      b = { fg = c('fg_status'), bg = c('bg_status', -0.1) },
      c = { fg = c('fg_status'), bg = c('bg_status') },
    },

    insert = { a = { fg = c('bg'), bg = c('green'), gui = 'bold' } },

    visual = { a = { fg = c('bg'), bg = c('purple'), gui = 'bold' } },

    replace = { a = { fg = c('bg'), bg = c('red'), gui = 'bold' } },

    inactive = {
      a = { fg = c('bg'), bg = c('selection') },
    },
  }
end

-- update the lualine colors based on the current vim colorscheme
-- this is somewhat fragile as it depends on knowing what highlight groups are
-- created by lualine
function exports.update_colors()
  local h = require('lualine.utils.utils').loaded_highlights
  local t = exports.get_theme()

  local function update_group(group, opts)
    local gname = 'lualine_' .. group
    h[gname][2] = opts.fg
    h[gname][3] = opts.bg
    h[gname][4] = opts.gui
  end

  update_group('a_normal', t.normal.a)
  update_group('a_insert', t.insert.a)
  update_group('a_visual', t.visual.a)
  update_group('a_replace', t.replace.a)
  update_group('a_inactive', t.inactive.a)
  update_group('b_normal', t.normal.b)
  update_group('c_normal', t.normal.c)
  update_group('a_normal_to_lualine_b_normal', t.normal.b)
  update_group('b_normal_to_lualine_a_normal', t.normal.b)
  update_group('b_normal_to_lualine_c_normal', t.normal.c)
  update_group('c_normal_to_lualine_b_normal', t.normal.c)
  update_group('c_filetype_icon_normal', t.normal.c)
  update_group('a_normal_to_lualine_c_filetype_icon_normal', t.normal.c)
  update_group('b_normal_to_lualine_c_filetype_icon_normal', t.normal.c)
end

return exports
