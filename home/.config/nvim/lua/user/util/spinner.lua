local progress = require('fidget.progress')

local handles = {}

local function store_progress_handle(id, handle)
  handles[id] = handle
end

local function pop_progress_handle(id)
  local handle = handles[id]
  handles[id] = nil
  return handle
end

local function llm_role_title(adapter)
  local parts = {}
  table.insert(parts, adapter.formatted_name)
  if adapter.model and adapter.model ~= '' then
    table.insert(parts, '(' .. adapter.model .. ')')
  end
  return table.concat(parts, ' ')
end

local function create_progress_handle(request)
  return progress.handle.create({
    title = ' Requesting assistance (' .. request.data.strategy .. ')',
    message = 'In progress...',
    lsp_client = {
      name = llm_role_title(request.data.adapter),
    },
  })
end

local function report_exit_status(handle, request)
  if request.data.status == 'success' then
    handle.message = 'Completed'
  elseif request.data.status == 'error' then
    handle.message = ' Error'
  else
    handle.message = '󰜺 Cancelled'
  end
end

local M = {}

M.init_code_companion = function()
  local group = vim.api.nvim_create_augroup('CodeCompanionFidgetHooks', {})

  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequestStarted',
    group = group,
    callback = function(request)
      local handle = create_progress_handle(request)
      store_progress_handle(request.data.id, handle)
    end,
  })

  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequestFinished',
    group = group,
    callback = function(request)
      local handle = pop_progress_handle(request.data.id)
      if handle then
        report_exit_status(handle, request)
        handle:finish()
      end
    end,
  })
end

return M
