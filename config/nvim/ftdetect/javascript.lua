vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*',
  callback = function()
    local line = vim.fn.getline(1)
    if line == '#!/usr/bin/osascript -l JavaScript' or line == '#!/usr/bin/env zx' then
      vim.o.filetype = 'javascript'
    end
  end
})
