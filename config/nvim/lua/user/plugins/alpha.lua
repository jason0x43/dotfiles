-- Useful startup text, menu
return {
  'goolord/alpha-nvim',

  dependencies = 'nvim-web-devicons',

  opts = function()
    local startify = require('alpha.themes.startify')

    startify.section.header.val = {
      ' ____ ____ ____ ____ ____ ____ ',
      '||n |||e |||o |||v |||i |||m ||',
      '||__|||__|||__|||__|||__|||__||',
      '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
    }

    startify.opts.layout[5] = startify.section.mru_cwd
    startify.opts.layout[6] = startify.section.mru

    -- update the title of the mru section and only show 5 items
    startify.section.mru.val[2].val = 'Recent'
    startify.section.mru.val[4].val = function()
      return { startify.mru(5, nil, 5) }
    end

    -- Add padding to the end of the mru section
    table.insert(startify.section.mru.val, {
      type = 'padding',
      val = 1,
    })

    -- update the title of the mru_cwd section and only show 5 items
    startify.section.mru_cwd.val[2].val = function()
      return 'Recent (cwd)'
    end
    startify.section.mru_cwd.val[4].val = function()
      return { startify.mru(0, vim.fn.getcwd(), 5) }
    end

		return startify.opts
  end,
}
