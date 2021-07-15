local FileTypeIcon = require('lualine.component'):new()
local devicons = require('nvim-web-devicons')

FileTypeIcon.update_status = function()
  return devicons.get_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
end

return FileTypeIcon
