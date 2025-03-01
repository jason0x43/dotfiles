local C = require('user.util.lsp').make_user_config()

C.should_start = function(file)
  local tailwindCfg = vim.fs.root(
    file,
    {
      'tailwind.config.ts',
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
    }
  )
  return tailwindCfg ~= nil
end

return C
