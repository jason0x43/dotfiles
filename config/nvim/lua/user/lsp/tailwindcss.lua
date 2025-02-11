local C = require('user.util.lsp').make_user_config()

C.config.root_dir = function(file)
  return vim.fs.root(file, { 
    'tailwind.config.cjs',
    'tailwind.config.js',
    'tailwind.config.ts'
  )(fname)
end
