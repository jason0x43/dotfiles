local M = {}

local lsp_find_root = require('lspconfig.util').root_pattern(
  'package.json',
  'deps.ts',
  'mod.ts',
  '.git'
)

local function find_root(filename)
  local dir = lsp_find_root(filename)
  if dir ~= nil then
    return dir
  end

  -- return the files path as the default root
  return vim.fn.fnamemodify(filename, ':h')
end

M.config = {
  autostart = false,
  root_dir = find_root,
}

function M.check_start()
  -- start the deno server if there's no tsconfig
  if
    vim.fn.findfile('tsconfig.json', '.;') == ''
    and vim.fn.findfile('jsconfig.json', '.;') == ''
  then
    require('lspconfig').denols.autostart()
  end
end

local util = require('util')

util.augroup('init_deno', {
  'FileType '
    .. util.ts_types_str()
    .. ' lua require("lsp.denols").check_start()',
})

return M
