local FileTypeIcon = require('lualine.component'):new()

FileTypeIcon.update_status = function()
  return require('nvim-web-devicons').get_icon(
    vim.fn.expand('%:t'),
    vim.fn.expand('%:e')
  )
end

return FileTypeIcon
