local M = {}

M.config = function()
  require('user.req')('copilot', function(copilot)
    vim.schedule(function()
      copilot.setup()
    end)
  end)
end

return M
