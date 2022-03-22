local M = {}

M.config = function()
  require('user.req')('nvim-lightulb', function()
    vim.cmd(
      'autocmd CursorHold,CursorHoldI * lua require("nvim-lightbulb").update_lightbulb()'
    )
  end)
end

return M
