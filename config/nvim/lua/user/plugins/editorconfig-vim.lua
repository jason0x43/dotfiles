local M = {}

M.setup = function()
  -- Don't let editorconfig set the max line -- it's handled via an
  -- autocommand
  vim.g.EditorConfig_max_line_indicator = 'none'
end

return M
