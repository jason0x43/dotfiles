local FileStatus = require('lualine.component'):extend()

function FileStatus:update_status()
  local status = ''

  if vim.bo.readonly then
    status = status .. '-'
  end

  if vim.bo.modified then
    status = status .. '+'
  end

  return status
end

return FileStatus

