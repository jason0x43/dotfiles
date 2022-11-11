local M = {}

M.config = function()
  require('trouble').setup()
  require('user.util').lmap('ed', '<cmd>Trouble document_diagnostics<cr>')
  require('user.util').lmap('ew', '<cmd>Trouble workspace_diagnostics<cr>')
end

return M
