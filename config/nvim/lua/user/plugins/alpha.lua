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

  startify.opts.layout[5] = startify.section.mru_cwd
  -- startify.opts.layout[6] = {
  --   type = 'group',
  --   val = {
  --     { type = 'padding', val = 1 },
  --     { type = 'text', val = 'Modified', opts = { hl = 'SpecialComment' } },
  --     { type = 'padding', val = 1 },
  --     {
  --       type = 'group',
  --       val = function()
  --         local files = vim.fn.systemlist('git ls-files -m')
  --         local buttons = {}
  --         for i, f in ipairs(files) do
  --           if i < 5 then
  --             local file_button = startify.file_button(f, tostring(i + 4), f)
  --             buttons[i] = file_button
  --           end
  --         end
  --         return buttons
  --       end,
  --     },
  --   },
  -- }
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
  startify.section.mru_cwd.val[2].val = 'Recent (cwd)'
  startify.section.mru_cwd.val[4].val = function()
    return { startify.mru(0, vim.fn.getcwd(), 5) }
  end

  require('alpha').setup(startify.opts)
end

return M
