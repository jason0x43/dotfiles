local M = {}

---@class(exact) MiniGitEventData
---@field git_command string[]
---@field git_subcommand string
---@field win_stdout? integer
---@field win_source? integer
---@field stdout? string
---@field stderr? string
---@field exit_code? integer

---@class MiniGitEvent
---@field data MiniGitEventData

---Modify how git blame output is displayed
---@param data MiniGitEventData
M.show_git_blame = function(data)
  -- Format the blame output
  local str = require('user.util.string')
  local random_rgb = require('user.util.color').random_rgb
  local hash_size = 0
  local name_size = 0
  local time_size = 0
  ---@type table<string, string>
  local colors = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local line_parts = vim.tbl_map(function(line)
    local parts = str.split(line, '\t')
    local hash = parts[1]
    if colors[hash] == nil then
      local group = 'blamehash_' .. hash
      vim.api.nvim_set_hl(0, group, { fg = random_rgb(vim.o.background) })
      colors[hash] = group
    end
    hash_size = math.max(hash_size, #hash)
    local name = parts[2]:sub(2)
    name_size = math.max(name_size, #name)
    local time = str.trim(parts[3])
    time_size = math.max(time_size, #time)
    return { hash = hash, name = name, time = time }
  end, lines)

  for i, lp in ipairs(line_parts) do
    lines[i] = string.format(
      '%s %s %s',
      str.rpad(lp.hash, hash_size),
      str.rpad(lp.name, name_size),
      str.rpad(lp.time, time_size)
    )
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace('blame')

  for i, parts in ipairs(line_parts) do
    i = i - 1

    if parts.name:find('Not Committed') then
      vim.hl.range(0, ns, 'Comment', { i, 0 }, { i, -1 })
    else
      vim.hl.range(0, ns, colors[parts.hash], { i, 0 }, { i, hash_size })
      vim.hl.range(
        0,
        ns,
        'String',
        { i, hash_size + 1 },
        { i, hash_size + 1 + name_size + 1 }
      )
    end

    -- Allow author to be toggled
    vim.api.nvim_buf_set_extmark(0, ns, i, hash_size + 1, {
      end_col = hash_size + 1 + name_size + 1,
      conceal = '',
    })
  end

  -- Setup the blame window
  vim.bo.modifiable = false
  vim.wo.concealcursor = 'n'
  vim.wo.conceallevel = 2

  -- Set the blame window width; adjust if author is toggled
  local blame_width = hash_size + 1 + time_size
  vim.api.nvim_win_set_width(data.win_stdout, blame_width)
  vim.keymap.set('n', ' ', function()
    local width = hash_size + 1 + time_size
    if vim.wo.conceallevel == 2 then
      width = width + name_size + 1
      vim.wo.conceallevel = 0
    else
      vim.wo.conceallevel = 2
    end
    vim.api.nvim_win_set_width(data.win_stdout, width)
  end, { buffer = 0 })

  -- Align blame output with source
  local win_src = data.win_source
  vim.wo.wrap = false
  vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
  vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

  -- Bind both windows so that they scroll together
  vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
end

return M
