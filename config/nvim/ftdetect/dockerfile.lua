vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'Dockerfile*',
  callback = function()
    vim.bo.filetype = 'dockerfile'
  end
})
