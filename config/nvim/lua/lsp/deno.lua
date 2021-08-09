local exports = {}

local lsp_find_root = require('lspconfig.util').root_pattern('package.json', 'tsconfig.json', '.git')

local function find_root(start_dir)
  local dir = lsp_find_root(start_dir)
  if dir ~= nil then
    return dir
  end
  return vim.fn.getcwd()
end

exports.config = {
  autostart = false,
  root_dir = find_root
}

function exports.check_start()
  -- start the deno server if there's no tsconfig
  if vim.fn.findfile('tsconfig.json', '.;') == '' then
    require('lspconfig').deno.autostart()
  end
end

local util = require('util')
local ts_types_str = table.concat(util.ts_types, ',')

util.augroup('init_deno', {
  'FileType ' .. ts_types_str .. ' lua require("lsp.deno").check_start()',
})

return exports
