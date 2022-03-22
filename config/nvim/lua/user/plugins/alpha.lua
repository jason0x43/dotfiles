local M = {}

M.config = function()
  local startify = require('user.req')('alpha.themes.startify')
  if not startify then
    return
  end

  startify.section.header.val = {
    ' ____ ____ ____ ____ ____ ____ ',
    '||n |||e |||o |||v |||i |||m ||',
    '||__|||__|||__|||__|||__|||__||',
    '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
  }

  -- switch the mru and mru_cwd section order
  startify.opts.layout[5] = startify.section.mru_cwd
  startify.opts.layout[6] = startify.section.mru

  table.insert(startify.opts.layout, 7, {
    type = 'padding',
    val = 1,
  })

  startify.section.bookmarks = {
    type = 'group',
    val = {
      {
        type = 'text',
        val = 'Bookmarks',
        opts = { hl = 'SpecialComment' },
      },
      { type = 'padding', val = 1 },
      {
        type = 'group',
        val = {
          startify.file_button(
          '~/.config/nvim/lua/user/plugins/init.lua',
          'c'
          ),
          startify.file_button('~/.zshrc', 'z'),
        },
      },
    },
  }

  table.insert(startify.opts.layout, 8, startify.section.bookmarks)

  -- update the title of the mru section and only show 5 items
  startify.section.mru.val[2].val = 'Recent'
  startify.section.mru.val[4].val = function()
    return { startify.mru(5, nil, 5) }
  end

  -- update the title of the mru_cwd section and only show 5 items
  startify.section.mru_cwd.val[2].val = 'Recent (cwd)'
  startify.section.mru_cwd.val[4].val = function()
    return { startify.mru(0, vim.fn.getcwd(), 5) }
  end

  require('alpha').setup(startify.opts)
end

return M
