local M = {}

---@type table<number, boolean>
local messages = {}

---Show a toast message
---@param msg string The message to show
---@param timeout? number How long to show the message (in milliseconds). Default: 2000
function M.toast(msg, timeout)
  -- Clean up stale entries (windows that closed while event loop was blocked)
  for win in pairs(messages) do
    if not vim.api.nvim_win_is_valid(win) then
      messages[win] = nil
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })

  local width = #msg + 2
  local row = vim.o.lines - 5 - 2 * vim.tbl_count(messages)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    row = row,
    col = vim.o.columns / 2 - width / 2,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    noautocmd = true,
  })

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
      messages[win] = nil
    end
  end, timeout or 2000)

  messages[win] = true
end

return M
