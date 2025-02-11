local C = require('user.util.lsp').make_user_config()

C.config.root_dir = function(file)
  return vim.fs.root(file, { 'deno.json', 'deno.jsonc' })
end
C.config.init_options = {
  formatter = true,
  lint = true,
  unstable = true,
}
C.config.single_file_support = true

C.should_start = function(file)
  if vim.fs.root(file, { 'deno.json', 'deno.jsonc' }) then
    return true
  end

  local first_line = vim.fn.getline(1)
  if first_line:find('#!/usr/bin/env %-S deno') ~= nil then
    return true
  end

  return false
end

return C
