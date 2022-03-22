local M = {}

M.config = function()
  vim.g.undotree_DiffAutoOpen = 0
  vim.g.undotree_SetFocusWhenToggle = 1
  require('user.util').lmap('u', '<cmd>UndotreeToggle<cr>')
end

return M
