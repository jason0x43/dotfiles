local M = {}

M.setup = function()
  -- Don't let editorconfig set the max line -- it's handled via an
  -- autocommand
  vim.g.EditorConfig_max_line_indicator = 'none'
  vim.g.EditorConfig_disable_rules = {
    'trim_trailing_whitespace',
    'insert_final_newline',
  }
end

return M