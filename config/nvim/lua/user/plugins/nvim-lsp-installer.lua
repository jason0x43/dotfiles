local M = {}

M.config = function()
  local req = require('user.req')
  req('nvim-lsp-installer', function(installer)
    installer.on_server_ready(function(server)
      local name = server.name
      local config = require('user.lsp').get_lsp_config(name)
      server:setup(config)

      req('user.lsp.' .. name, function(user_server)
        if user_server.start then
          user_server.start()
        end
      end)
    end)
  end)
end

return M
