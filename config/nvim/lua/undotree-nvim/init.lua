-- This code is based on telescope-undo

local utils = require('fzf-lua.utils')

local M = {}

-- how many lines of context to show around each diff
local context_lines = 3

local function _build_tree(entries, level)
  local undolist = {}

  -- create diffs for each entry in undotree
  for i = #entries, 1, -1 do
    -- grab the buffer as it is after this iteration's undo state
    vim.cmd('silent undo ' .. entries[i].seq)
    local buffer_after_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
    local buffer_after = table.concat(buffer_after_lines, '\n')

    -- grab the buffer as it is after this undo state's parent
    vim.cmd('silent undo')
    local buffer_before_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      or {}
    local buffer_before = table.concat(buffer_before_lines, '\n')

    -- add a diff file header for this hunk for delta
    local filename = vim.fn.expand('%')
    local diff = '--- ' .. filename .. '\n+++ ' .. filename .. '\n'

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

    table.insert(undolist, {
      seq = entries[i].seq,
      alt = level,
      first = i == #entries,
      time = entries[i].time,
      diff = diff,
    })

    -- if the entry has an alt branch, generate undo items for that and add it
    -- to the undolist
    if entries[i].alt ~= nil then
      local alt_undolist = _build_tree(entries[i].alt, level + 1)
      for _, elem in pairs(alt_undolist) do
        table.insert(undolist, elem)
      end
    end
  end

  return undolist
end

local function build_tree(ut)
  -- save the cursor position -- it will need to be restored after building the
  -- tree, which changes the buffer while creating diffs
  local cursor = vim.api.nvim_win_get_cursor(0)

  local undolist = _build_tree(ut.entries, 0)

  -- restore the buffer and cursor after building the tree
  vim.cmd('silent undo ' .. ut.seq_cur)
  vim.api.nvim_win_set_cursor(0, cursor)

  return undolist
end

local function time_value(value, unit)
  if value == 1 then
    return string.format('%d %s', value, unit)
  end
  return string.format('%d %ss', value, unit)
end

local function round(val)
  return math.floor(val + 0.5)
end

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

local function render_undo_entry(undo, seq_cur)
  -- the following prefix should work out to this graph structure:
  -- state #1
  -- └─state #2
  -- state #3
  -- ├─state #4
  -- └─state #5
  -- state #6
  -- ├─state #7
  -- ┆ ├─state #8
  -- ┆ └─state #9
  -- └─state #10
  local prefix = ''
  if undo.alt > 0 then
    prefix = string.rep('│ ', undo.alt)
    if undo.first then
      local corner = '┌'
      prefix = prefix .. corner .. '╴'
    else
      prefix = prefix .. '├╴'
    end
  end

  local seq
  if undo.seq == seq_cur then
    seq = utils.ansi_codes.red(utils.ansi_codes.bold(tostring(undo.seq)))
  else
    seq = utils.ansi_codes.white(utils.ansi_codes.italic(tostring(undo.seq)))
  end

  local time = utils.ansi_codes.blue(time_ago(undo.time))

  local line = undo.seq .. ':' .. prefix .. seq .. ' ' .. time

  if undo.seq == seq_cur then
    line = utils.ansi_codes.yellow(utils.ansi_codes.bold(line))
  end

  return line
end

M.undotree = function()
  local ut = vim.fn.undotree()
  if #ut.entries <= 1 then
    vim.notify('No undo history', vim.log.levels.WARN)
    return
  end

  local tree = build_tree(ut)
  local lines = {}
  local entries = {}

  for _, entry in pairs(tree) do
    lines[#lines + 1] = render_undo_entry(entry, ut.seq_cur)
    entries[tostring(entry.seq)] = entry
  end

  require('fzf-lua').fzf_exec(lines, {
    actions = {
      ['default'] = function(selected)
        local item = selected[1]
        local seq = item:match('^(%d+)')
        vim.cmd('silent undo ' .. seq)
      end,
    },
    fzf_opts = {
      ['--phony'] = '',
      ['--delimiter'] = ':',
      ['--with-nth'] = '2',
      ['--preview-window'] = 'nohidden,right,75%,border-left',
      ['--preview'] = require('fzf-lua').shell.action(function(items)
        local contents = {}
        vim.tbl_map(function(item)
          local seq = item:match('^(%d+)')
          local diff = entries[seq].diff
          local hldiff = vim.fn.system('delta --diff-highlight', diff)
          table.insert(contents, hldiff)
        end, items)
        return contents
      end),
    },
  })
end

M.setup = function()
  local ok, _ = pcall(require, 'fzf-lua')
  if not ok then
    vim.notify('undotree-nvim requires fzf-lua', vim.log.levels.WARN)
    return
  end
end

return M
