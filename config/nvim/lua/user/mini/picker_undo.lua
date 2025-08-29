-- This code is based on telescope-undo

local M = {}

-- how many lines of context to show around each diff
local context_lines = 3

---@alias UndoTreeEntry
---|  { seq: number, time: number, save?: number, curhead?: boolean }
---@alias UndoTree
---|  { seq_cur: number, entries: UndoTreeEntry[] }
---@alias UndoListEntry
---|  { seq: number, alt: number, is_first: boolean, is_next: boolean, time: number }
---@alias UndoList
---|  UndoListEntry[]

-- return true of the string str starts with the string other
---@param str string
---@param other string
---@return boolean
local starts_with = function(str, other)
  return str:sub(1, #other) == other
end

---@param entries table
---@param level number
---@return UndoList
local function _build_tree(entries, level)
  ---@type UndoList
  local undolist = {}

  for i = #entries, 1, -1 do
    undolist[#undolist + 1] = {
      seq = entries[i].seq,
      alt = level,
      is_first = i == #entries,
      is_next = entries[i].curhead ~= nil,
      time = entries[i].time,
    }

    -- if the entry has an alt branch, generate undo items for that and add them
    -- to the undolist
    if entries[i].alt ~= nil then
      local alt_undolist = _build_tree(entries[i].alt, level + 1)
      for _, elem in pairs(alt_undolist) do
        undolist[#undolist + 1] = elem
      end
    end
  end

  return undolist
end

---@param ut UndoTree
---@return UndoList | nil
local function build_tree(ut)
  local ok, undolist = pcall(function()
    return _build_tree(ut.entries, 0)
  end)
  if not ok then
    vim.notify('Error building undo list\n' .. undolist, vim.log.levels.ERROR)
    return nil
  end

  return undolist
end

---@param seq number
---@return string
local function _get_diff(seq)
  -- grab the buffer as it is after this iteration's undo state
  vim.cmd('silent undo ' .. seq)
  local buffer_after_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
  local buffer_after = table.concat(buffer_after_lines, '\n')

  -- grab the buffer as it is after this undo state's parent
  vim.cmd('silent undo')
  local buffer_before_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
  local buffer_before = table.concat(buffer_before_lines, '\n')

  -- add a diff file header for this hunk for delta
  local filename = vim.fn.expand('%')
  ---@type string
  local diff = '--- ' .. filename .. '\n+++ ' .. filename .. '\n'

  ---@param start_a number
  ---@param count_a number
  ---@param start_b number
  ---@param count_b number
  local on_hunk_callback = function(start_a, count_a, start_b, count_b)
    -- add a diff location header for this hunk for delta
    diff = diff .. '@@ -' .. start_a
    if count_a ~= 1 then
      diff = diff .. ',' .. count_a
    end
    diff = diff .. ' +' .. start_b
    if count_b ~= 1 then
      diff = diff .. ',' .. count_b
    end
    diff = diff .. ' @@'

    -- add context before diff
    for x = start_a - context_lines, start_a - 1 do
      if buffer_before_lines[x] ~= nil then
        diff = diff .. '\n ' .. buffer_before_lines[x]
      end
    end

    -- add deletions
    for j = start_a, start_a + count_a - 1 do
      diff = diff .. '\n-' .. buffer_before_lines[j]
    end

    -- add additions
    for k = start_b, start_b + count_b - 1 do
      diff = diff .. '\n+' .. buffer_after_lines[k]
    end

    -- add context after diff
    for n = start_a + count_a, start_a + count_a + context_lines - 1 do
      if buffer_before_lines[n] ~= nil then
        diff = diff .. '\n ' .. buffer_before_lines[n]
      end
    end

    -- end with a newline
    diff = diff .. '\n'
  end

  vim.diff(buffer_before, buffer_after, {
    result_type = 'indices',
    on_hunk = on_hunk_callback,
    algorithm = 'patience',
  })

  return diff
end

---@param seq number
---@param seq_cur number
---@return nil | string
local function get_diff(seq, seq_cur)
  -- save the cursor position -- it will need to be restored after building the
  -- tree, which changes the buffer while creating diffs
  local savedview = vim.fn.winsaveview()

  local ok, diff = pcall(function()
    return _get_diff(seq)
  end)

  -- restore the buffer and cursor after building the tree
  vim.cmd('silent undo ' .. seq_cur)
  vim.fn.winrestview(savedview)

  assert(ok, 'Error generating diff\n' .. diff)

  return diff
end

---@param value number
---@param unit string
---@return string
local function time_value(value, unit)
  if value == 1 then
    return string.format('%d %s ago', value, unit)
  end
  return string.format('%d %ss ago', value, unit)
end

---@param val number
---@return number
local function round(val)
  return math.floor(val + 0.5)
end

---@param time number
---@return string
local function time_ago(time)
  local now = os.time()

  local seconds = os.difftime(now, time)
  if seconds < 60 then
    return time_value(seconds, 'second')
  end

  local minutes = round(seconds / 60)
  if minutes < 60 then
    return time_value(minutes, 'minute')
  end

  local hours = round(seconds / (60 * 60))
  if hours < 24 then
    return time_value(hours, 'hour')
  end

  local days = round(seconds / (60 * 60 * 24))
  if days < 7 then
    return time_value(days, 'day')
  end

  local weeks = round(seconds / (60 * 60 * 24 * 7))
  if weeks < 52 then
    return time_value(weeks, 'week')
  end

  local years = round(seconds / (60 * 60 * 24 * 7 * 52))
  return time_value(years, 'year')
end

---@param undo UndoListEntry
---@param seq_cur number
---@return string
local function render_undo_entry(undo, seq_cur)
  -- the following prefix should work out to this graph structure:
  -- state #10
  -- │ ┌╴state #8
  -- │ ├╴state #9
  -- state #7
  -- state #6
  -- │ ┌╴state #5
  -- │ ├╴state #4
  -- state #3
  -- │ ┌╴state #2
  -- state #1
  local prefix = ''
  if undo.alt > 0 then
    prefix = ' │ ' .. string.rep('│ ', undo.alt - 1)
    if undo.is_first then
      prefix = prefix .. '┌╴'
    else
      prefix = prefix .. '├╴'
    end
  end

  ---@type string
  local seq

  if undo.seq == seq_cur then
    seq = string.format('>%d<', undo.seq)
  elseif undo.is_next then
    seq = string.format('{%d}', undo.seq)
  else
    seq = string.format(' %d ', undo.seq)
  end

  local time = time_ago(undo.time)
  local line = undo.seq .. ':' .. prefix .. seq .. ' ' .. time

  ---@type string
  return line
end

---@param item string
---@return number
local function get_seq(item)
  local seq = tonumber(item:match('^(%d+)'))
  assert(seq ~= nil, 'Invalid seq in "' .. item .. '"')
  return seq
end

local function highlight_line(buf_id, ns, line, group)
  vim.hl.range(buf_id, ns, group, { line, 0 }, { line, -1 })
end

return function()
  local buf = vim.api.nvim_get_current_buf()

  ---@type UndoTree
  local ut = vim.fn.undotree()

  if #ut.entries <= 1 then
    vim.notify('No undo history')
    return
  end

  local tree = build_tree(ut)
  if tree == nil then
    return
  end

  ---@type string[]
  local lines = {}
  for _, entry in pairs(tree) do
    lines[#lines + 1] = render_undo_entry(entry, ut.seq_cur)
  end

  require('mini.pick').start({
    source = {
      items = lines,
      choose = function(item)
        local seq = get_seq(item)
        vim.api.nvim_win_call(
          MiniPick.get_picker_state().windows.target,
          function()
            vim.cmd('silent undo ' .. seq)
          end
        )
      end,
      preview = function(buf_id, item)
        local seq = get_seq(item)
        local ok, diff_or_error = pcall(
          ---@return string | nil
          function()
            return vim.api.nvim_buf_call(buf, function()
              return get_diff(seq, ut.seq_cur)
            end)
          end
        )

        local dlines = {}
        if diff_or_error ~= nil then
          dlines = vim.fn.split(diff_or_error, '\n')
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, dlines)
        local ns = vim.api.nvim_create_namespace('undotree')

        if diff_or_error ~= nil and ok then
          for i = 0, #dlines - 1 do
            local line = dlines[i + 1]
            if starts_with(line, '--- ') then
              highlight_line(buf_id, ns, i, 'diffOldFile')
            elseif starts_with(line, '+++ ') then
              highlight_line(buf_id, ns, i, 'diffNewFile')
            elseif starts_with(line, '@@ ') then
              highlight_line(buf_id, ns, i, 'diffLine')
            elseif starts_with(line, '- ') then
              highlight_line(buf_id, ns, i, 'diffRemoved')
            elseif starts_with(line, '+ ') then
              highlight_line(buf_id, ns, i, 'diffAdded')
            end
          end
        end
      end,
    },
  })
end
