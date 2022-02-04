local path = require('lspconfig.util').path

local function get_root_dir(server)
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local config = require('lspconfig')[server]
  return config.get_root_dir(path.sanitize(bufname), bufnr)
end

local M = {}

function M.create_start(server)
  return function()
    if get_root_dir(server) then
      vim.cmd('LspStart ' .. server)
    end
  end
end

function M.create_autostart_autocmd(server, filetypes)
  local ft_str = table.concat(filetypes, ',')
  require('user.util').augroup('autostart_' .. server, {
    'FileType '
      .. ft_str
      .. ' lua require("user.lsp.'
      .. server
      .. '").start()',
  })
end

return M
