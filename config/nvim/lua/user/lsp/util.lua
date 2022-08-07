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
  local group = 'autostart_' .. server
  vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = ft_str,
    callback = function()
      require('user.lsp.' .. server).start()
    end
  })
end

function M.disable_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
end

return M
