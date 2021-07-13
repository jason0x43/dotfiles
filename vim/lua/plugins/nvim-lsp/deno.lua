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

util.augroup('init_deno', {
  'FileType ' .. util.ts_types .. ' lua deno.check_start()',
})

_G.deno = exports
return exports
