local NS = vim.api.nvim_create_namespace('EASYMOTION_NS')
local LABEL_CHARS =
  vim.split('fjdkslgha;rueiwotyqpvbcnxmzFJDKSLGHARUEIWOTYQPVBCNXMZ', '')

-- all printable chars we want to capture
local PRINTABLE = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  .. '`~!@#$%^&*()-_=+[{]}\\|;:\'",<.>/?'

local M = {}

---@class JumpState
---@field chars string[]
---@field extmarks table<string, {line: integer, col: integer, id: integer}>
---@field bufnr integer

---@type JumpState|nil
local state = nil

--- Highlight all matches of the typed chars in the visible window
---@param needle string
local function highlight_matches(needle)
  if not state or #needle == 0 then
    return
  end

  local line_idx_start, line_idx_end = vim.fn.line('w0'), vim.fn.line('w$')
  local lines = vim.api.nvim_buf_get_lines(
    state.bufnr,
    line_idx_start - 1,
    line_idx_end,
    false
  )

  local is_case_sensitive = needle ~= string.lower(needle)

  for lines_i, line_text in ipairs(lines) do
    local search_text = is_case_sensitive and line_text
      or string.lower(line_text)
    local line_idx = lines_i + line_idx_start - 1

    -- skip folded lines
    if vim.fn.foldclosed(line_idx) == -1 then
      local col = 1
      while col <= #search_text do
        if search_text:sub(col, col + #needle - 1) == needle then
          local linenr = line_idx_start + lines_i - 2
          vim.api.nvim_buf_set_extmark(state.bufnr, NS, linenr, col - 1, {
            end_col = col - 1 + #needle,
            hl_group = 'Search',
          })
          col = col + #needle
        else
          col = col + 1
        end
      end
    end
  end
end

local function cleanup()
  if not state then
    return
  end

  vim.cmd('echom ""')

  -- clear extmarks
  vim.api.nvim_buf_clear_namespace(state.bufnr, NS, 0, -1)

  -- remove keymaps
  for i = 1, #PRINTABLE do
    local char = PRINTABLE:sub(i, i)
    pcall(vim.keymap.del, 'n', char, { buffer = state.bufnr })
  end
  pcall(vim.keymap.del, 'n', '<Esc>', { buffer = state.bufnr })
  pcall(vim.keymap.del, 'n', '<BS>', { buffer = state.bufnr })
  pcall(vim.keymap.del, 'n', '<C-h>', { buffer = state.bufnr })
  pcall(vim.keymap.del, 'n', '<Space>', { buffer = state.bufnr })

  state = nil
end

---@param extmarks table<string, {line: integer, col: integer, id: integer}>
---@param char1 string
---@param char2 string
local function find_matches(extmarks, char1, char2)
  local line_idx_start, line_idx_end = vim.fn.line('w0'), vim.fn.line('w$')
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

  local char_idx = 1
  local lines =
    vim.api.nvim_buf_get_lines(bufnr, line_idx_start - 1, line_idx_end, false)
  local needle = char1 .. char2

  local is_case_sensitive = needle ~= string.lower(needle)

  for lines_i, line_text in ipairs(lines) do
    local search_text = is_case_sensitive and line_text
      or string.lower(line_text)
    local line_idx = lines_i + line_idx_start - 1

    -- skip folded lines
    if vim.fn.foldclosed(line_idx) == -1 then
      for i = 1, #search_text do
        if search_text:sub(i, i + 1) == needle and char_idx <= #LABEL_CHARS then
          local overlay_char = LABEL_CHARS[char_idx]
          local linenr = line_idx_start + lines_i - 2
          local col = i - 1
          -- highlight the two matched characters with Search
          vim.api.nvim_buf_set_extmark(bufnr, NS, linenr, col, {
            end_col = col + 2,
            hl_group = 'Search',
          })
          -- show the label overlay after the two chars
          local id = vim.api.nvim_buf_set_extmark(bufnr, NS, linenr, col + 2, {
            virt_text = { { overlay_char, 'CurSearch' } },
            virt_text_pos = 'overlay',
            hl_mode = 'replace',
          })
          extmarks[overlay_char] = { line = linenr, col = col, id = id }
          char_idx = char_idx + 1
          if char_idx > #LABEL_CHARS then
            return
          end
        end
      end
    end
  end
end

---@param char string
local function handle_char(char)
  if not state then
    return
  end

  table.insert(state.chars, char)

  if #state.chars == 1 then
    -- highlight all matches of first char
    highlight_matches(state.chars[1])
  elseif #state.chars == 2 then
    -- find matches and show labels (clears previous highlights)
    find_matches(state.extmarks, state.chars[1], state.chars[2])
    if vim.tbl_isempty(state.extmarks) then
      cleanup()
    end
  elseif #state.chars >= 3 then
    -- jump to selected label
    local label = state.chars[3]
    if state.extmarks[label] then
      local pos = state.extmarks[label]
      -- to make <C-o> work
      vim.cmd("normal! m'")
      vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.col })
    end
    cleanup()
  end
end

local function handle_backspace()
  if not state then
    return
  end

  if #state.chars > 0 then
    table.remove(state.chars)
    -- clear extmarks
    vim.api.nvim_buf_clear_namespace(state.bufnr, NS, 0, -1)
    state.extmarks = {}
    -- re-show highlights if we still have chars
    if #state.chars > 0 then
      highlight_matches(table.concat(state.chars))
    end
  else
    -- backspace with no chars cancels
    cleanup()
  end
end

local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, nowait = true, silent = true }

  -- map all printable characters
  for i = 1, #PRINTABLE do
    local char = PRINTABLE:sub(i, i)
    vim.keymap.set('n', char, function()
      handle_char(char)
    end, opts)
  end

  -- space needs special handling
  vim.keymap.set('n', '<Space>', function()
    handle_char(' ')
  end, opts)

  -- escape to cancel
  vim.keymap.set('n', '<Esc>', function()
    cleanup()
  end, opts)

  -- backspace
  vim.keymap.set('n', '<BS>', handle_backspace, opts)
  vim.keymap.set('n', '<C-h>', handle_backspace, opts)
end

function M.jump()
  -- cleanup any existing state
  cleanup()

  vim.cmd('echom "Enter two characters..."')

  local bufnr = vim.api.nvim_get_current_buf()

  state = {
    chars = {},
    extmarks = {},
    bufnr = bufnr,
  }

  setup_keymaps(bufnr)
end

return M
