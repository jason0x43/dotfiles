local M = {}

M.project_root = function(file)
  return vim.fs.root(file, {
    'package.json',
    'deno.json',
    'pyproject.toml',
    'requirements.txt',
    'Cargo.toml',
    '.git'
  })
end

return M
