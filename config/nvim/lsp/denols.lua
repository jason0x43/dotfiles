local C = require('user.util.lsp').make_config()

C.root_dir = function(bufnr, on_dir)
  local root = require('user.util.lsp').get_deno_root(bufnr)
  if root then
    on_dir(root)
  end
end

C.init_options = {
  formatter = true,
  lint = true,
  unstable = true,
}

C.workspace_required = false

-- C.should_start = function(file)
--   if vim.fs.root(file, { 'deno.json', 'deno.jsonc' }) then
--     return true
--   end
--
--   local first_line = vim.fn.getline(1)
--   if first_line:find('#!/usr/bin/env %-S deno') ~= nil then
--     return true
--   end
--
--   return false
-- end

return C
