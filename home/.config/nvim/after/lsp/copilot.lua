-- Create a path value without mise/installs/node entries to ensure we're using
-- the system node.
local path_entries = vim.split(vim.env.PATH or '', ':', { trimempty = true })
local filtered = vim.tbl_filter(function(entry)
  return not string.find(entry, 'mise/installs/node', 1, true)
end, path_entries)
local path = table.concat(filtered, ':')

return {
  cmd_env = { PATH = path },
}
