local exports = {}

exports.config = {
  autostart = false,
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
