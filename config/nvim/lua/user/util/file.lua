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

--- Returns the appropriate JavaScript formatter based on project configuration
--- Priority: biome (if biome.json exists and biome is available)
---        -> deno_fmt (if deno.json exists and deno is available)
---        -> prettier (fallback)
---@param bufnr number|nil Buffer number (defaults to current buffer)
---@return string formatter name
M.format_js = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)

  -- Check for biome
  local biome_root = vim.fs.root(file, { 'biome.json' })
  if biome_root and vim.fn.executable('biome') == 1 then
    return 'biome'
  end

  -- Check for deno
  local deno_root = vim.fs.root(file, { 'deno.json', 'deno.jsonc' })
  if deno_root and vim.fn.executable('deno') == 1 then
    return 'deno_fmt'
  end

  -- Fallback to prettier
  return 'prettier'
end

return M
