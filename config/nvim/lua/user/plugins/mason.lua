local M = {}

M.config = function()
  require('mason').setup({
		ui = {
			border = 'rounded'
		}
  })
end

return M
