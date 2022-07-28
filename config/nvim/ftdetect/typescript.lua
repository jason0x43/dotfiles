vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*',
  callback = function()
    if vim.fn.getline(1) == '^#!/usr/bin/env deno' then
      vim.o.filetype = 'applescript'
    end
  end
})
