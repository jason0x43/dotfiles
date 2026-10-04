---@module 'mini.pick'

---A command picker
return function()
  local commands = vim.tbl_deep_extend(
    'force',
    vim.api.nvim_get_commands({}),
    vim.api.nvim_buf_get_commands(0, {})
  )

  local matching_items = vim.fn.getcompletion('', 'command')
  local max_width = 0
  for _, name in ipairs(matching_items) do
    if #name > max_width then
      max_width = #name
    end
  end

  local active_items = vim.tbl_filter(function(item)
    local data = commands[item]
    if data == nil then
      return true
    end
    if data.hidden or data.definition == 'deprecated' then
      return false
    end
    return true
  end, matching_items)

  local items = vim.tbl_map(function(item)
    ---@type string
    local text
    ---@type string
    local definition

    local data = commands[item]
    if data == nil or data.definition == nil then
      definition = ''
    else
      definition = string.format('%s', data.definition)
    end

    local padding = math.max(0, max_width - #item)
    local padded = item .. string.rep(' ', padding)
    text = string.format('%s │ %s', padded, definition)

    return {
      text = text,
      command = item,
    }
  end, active_items)

  MiniPick.start({
    source = {
      name = 'Command Bar',
      items = items,
      preview = function(buf_id, item)
        local data = commands[item]
        ---@type string[]
        local lines
        if data == nil or data.definition == nil then
          lines = { '' }
        else
          lines = { data.definition }
        end
        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      end,
      choose = function(item)
        local keys = string.format(':%s\r', item.command)
        vim.schedule(function()
          vim.fn.feedkeys(keys)
        end)
      end,
      choose_marked = function(item)
        local data = commands[item.command] or {}
        local keys = string.format(
          ':%s%s',
          item.command,
          data.nargs == '0' and '\r' or ' '
        )
        vim.schedule(function()
          vim.fn.feedkeys(keys)
        end)
      end,
    },
  })
end
