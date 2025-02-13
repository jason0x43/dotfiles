local M = {}

---Open a floating, read-only window in the middle of the active window
---@param config? vim.api.keyset.win_config
---@param opts? { lines?: string[], hide_cursor?: boolean }
M.open_float = function(config, opts)
  config = config or {}
  opts = opts or {}

  local bufnr = vim.api.nvim_create_buf(false, true)
  local width = config.width or 60
  local height = math.min(
    math.max(
      config.height or (opts.lines and #opts.lines) or vim.o.lines / 2,
      10
    ),
    vim.o.lines / 2
  )

  ---@type vim.api.keyset.win_config
  local cfg = vim.tbl_extend('force', {
    relative = 'editor',
    width = width,
    height = height,
    anchor = 'NW',
    col = vim.o.columns / 2 - width / 2,
    row = vim.o.lines / 2 - height / 2,
    border = 'rounded',
  }, config)

  local winnr = vim.api.nvim_open_win(bufnr, true, cfg)

  if opts.hide_cursor then
    local theme = require('user.themes.wezterm')
    theme.hide_cursor()
    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = { string.format('%s', winnr) },
      callback = function()
        theme.show_cursor()
      end,
    })
  end

  vim.bo[bufnr].filetype = 'temp-float'
  vim.wo[winnr].number = false
  vim.wo[winnr].fillchars = 'eob: '
  vim.wo[winnr].signcolumn = 'no'

  vim.keymap.set('n', 'j', '<c-e>', { buffer = bufnr, desc = 'Scroll down' })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(winnr, true)
  end, { buffer = bufnr, desc = 'Close the window' })
  vim.keymap.set('n', '<esc>', function()
    vim.api.nvim_win_close(winnr, true)
  end, { buffer = bufnr, desc = 'Close the window' })

  if opts and opts.lines then
    for i, line in ipairs(opts.lines) do
      vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { ' ' .. line })
    end
    vim.bo[bufnr].readonly = true
  end

  return { buffer = bufnr, window = winnr }
end

return M
