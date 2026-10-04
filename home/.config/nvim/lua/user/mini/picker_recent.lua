---A recent files picker
return function(local_opts)
  vim.v.oldfiles = vim.tbl_filter(function(item)
    return not vim.endswith(item, 'COMMIT_EDITMSG')
  end, vim.v.oldfiles)
  return require('mini.extra').pickers.oldfiles(local_opts)
end
