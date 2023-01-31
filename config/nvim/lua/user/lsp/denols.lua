local M = {}

local denols = require('lspconfig.server_configurations.denols')
local lspconfig = require('lspconfig')
local lsp_util = require('user.lsp.util')

M.config = {
  root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),

  init_options = {
    lint = true,
    unstable = true,
  },

  handlers = {
    ['textDocument/definition'] = function(err, result, ctx, config)
      -- If denols returns multiple results, goto the first local one
      if result and #result > 1 then
        result = { result[1] }
      end
      denols.default_config.handlers['textDocument/definition'](
        err,
        result,
        ctx,
        config
      )
    end,

    ['textDocument/codeAction'] = function(err, result, ctx, config)
      print('handling deno codeaction')
      denols.default_config.handlers['textDocument/codeAction'](
        err,
        result,
        ctx,
        config
      )
    end,
  },
}

local function score_code_action(result)
  local title = result.title
  -- imports first
  if title:find('Import ') == 1 then
    return 1
  end
  if title:find('Update ') == 1 then
    return 2
  end
  -- disable/ignore last
  if title:find('Disable ') == 1 or title:find('Ignore ') == 1 then
    return 5
  end
  return 4
end

-- Override buf_request_sync to sort codeAction results before they get to
-- Telescope
local buf_request_sync = vim.lsp.buf_request_sync
vim.lsp.buf_request_sync = function(bufnr, method, params, timeout_ms)
  local results, err = buf_request_sync(bufnr, method, params, timeout_ms)
  if method == 'textDocument/codeAction' and err == nil then
    for client_id, response in pairs(results) do
      if response.result then
        local client = vim.lsp.get_client_by_id(client_id)
        if client.name == 'denols' then
          table.sort(response.result, function(a, b)
            local aScore = score_code_action(a)
            local bScore = score_code_action(b)
            if aScore == bScore then
              return a.title < b.title
            end
            return aScore < bScore
          end)
        end
      end
    end
  end
  return results, err
end

return M
