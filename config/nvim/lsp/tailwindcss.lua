local C = require('user.util.lsp').make_config()

C.root_dir = function(bufnr, on_dir)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(file, {
    'tailwind.config.ts',
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
  })
  if root then
    on_dir(root)
  end
end

return C
