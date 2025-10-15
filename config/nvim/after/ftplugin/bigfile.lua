local buf = vim.api.nvim_get_current_buf()
local ft = vim.filetype.match({ buf = buf }) or ''

vim.api.nvim_buf_call(buf, function()
  if vim.fn.exists(':NoMatchParen') ~= 0 then
    vim.cmd([[NoMatchParen]])
  end
  vim.wo.foldmethod = 'manual'
  vim.wo.statuscolumn = ''
  vim.wo.conceallevel = 0
  vim.b.minianimate_disable = true
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf].syntax = ft
    end
  end)
end)
