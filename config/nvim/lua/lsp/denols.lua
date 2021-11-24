local M = {}

M.config = {
  single_file_support = true,

  should_attach = function()
    return vim.fn.findfile('deps.ts', '.;') ~= ''
      or vim.fn.findfile('mod.ts', '.;') ~= ''
      or (
        vim.fn.findfile('tsconfig.json', '.;') == ''
        and vim.fn.findfile('jsconfig.json', '.;') == ''
      )
  end,
}

return M
