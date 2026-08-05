-- Custom MiniPick pickers powered by fff.nvim's rust backend.

---File search
local function find_files(query)
  local ok, fff = pcall(require, 'fff')
  if not ok then
    return {}
  end

  local results = fff.file_search(query or '', { max_results = 100 })

  local items = {}
  for _, r in ipairs(results.items) do
    table.insert(items, {
      text = r.relative_path,
      path = r.relative_path,
    })
  end

  return items
end

---File content search (grep)
local function find_content(query)
  local ok, fff = pcall(require, 'fff')
  if not ok then
    return {}
  end

  local results = fff.content_search(query or '', {
    max_results = 100,
    mode = 'regex',
  })

  local items = {}
  for _, r in ipairs(results.items) do
    local content_prefix = string.format('%s|%d|%d|', r.relative_path, r.line_number, r.col)
    local text = content_prefix .. r.line_content
    text = text:gsub('%z', '│'):gsub('[\r\n]', ' '):gsub('\t', string.rep(' ', vim.o.tabstop))

    table.insert(items, {
      text = text,
      lnum = r.line_number,
      col = r.col,
      path = r.relative_path,
      line_content = r.line_content,
      content_prefix = content_prefix,
      match_ranges = r.match_ranges,
    })
  end

  return items
end

local function show(buf_id, items, query, show_opts)
  show_opts = vim.tbl_extend(
    'force',
    {},
    show_opts or {},
    { show_icons = true }
  )

  if not (items[1] and items[1].match_ranges) then
    return MiniPick.default_show(buf_id, items, query, show_opts)
  end

  MiniPick.default_show(buf_id, items, {}, show_opts)

  local ns = vim.api.nvim_create_namespace('user.mini.picker_fff')
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

  for row, item in ipairs(items) do
    local line = lines[row]
    if line and item.text and item.match_ranges then
      local item_start = line:find(item.text, 1, true)
      local content_start = item_start and (item_start - 1 + #item.content_prefix) or nil

      if content_start then
        for _, range in ipairs(item.match_ranges) do
          local start_col = content_start + (range[1] or 0)
          local end_col = content_start + (range[2] or 0)
          if start_col < end_col then
            vim.api.nvim_buf_set_extmark(buf_id, ns, row - 1, start_col, {
              end_col = end_col,
              hl_group = 'MiniPickMatchRanges',
              hl_mode = 'combine',
              priority = 250,
            })
          end
        end
      end
    end
  end
end

local M = {}

---Create a MiniPick matcher that safely replaces FFF search results.
---
---`set_picker_items()` updates asynchronously, so discard an update when the
---query changes before MiniPick has finished processing it.
---@param MiniPick table
---@param find fun(query: string): table
---@return fun(_: string[], _: number[], query: string[])
local function make_live_match(MiniPick, find)
  local set_items_opts = {
    do_match = false,
    querytick = MiniPick.get_querytick(),
  }

  return function(_, _, query)
    local querytick = MiniPick.get_querytick()
    if querytick == set_items_opts.querytick then
      return
    end

    set_items_opts.querytick = querytick
    if #query == 0 then
      return MiniPick.set_picker_items({}, set_items_opts)
    end

    MiniPick.set_picker_items(find(table.concat(query)), set_items_opts)
  end
end

---Choose a content-search result after any BufWinEnter cursor restoration.
---@param MiniPick table
---@param item table
local function choose_content(MiniPick, item)
  local state = MiniPick.get_picker_state()
  local target_win = state and state.windows.target or vim.api.nvim_get_current_win()

  MiniPick.default_choose(item)

  -- The global BufWinEnter autocmd restores the `"` mark. Reapply an explicit
  -- picker location after that autocmd has had a chance to run.
  if item.lnum == nil then
    return
  end

  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(target_win) then
      return
    end

    local col = math.max((item.col or 1) - 1, 0)
    vim.api.nvim_win_set_cursor(target_win, { item.lnum, col })
    vim.api.nvim_win_call(target_win, function()
      vim.cmd('normal! zvzz')
    end)
  end)
end

M.files = function(local_opts)
  local MiniPick = require('mini.pick')

  local opts = vim.tbl_deep_extend('force', {
    source = {
      name = 'fff_files',
      items = {},
      match = make_live_match(MiniPick, find_files),
      show = show,
    },
  }, local_opts)

  MiniPick.start(opts)
end

M.content = function(local_opts)
  local MiniPick = require('mini.pick')

  local opts = vim.tbl_deep_extend('force', {
    source = {
      name = 'fff_content',
      items = {},
      match = make_live_match(MiniPick, find_content),
      show = show,
      choose = function(item)
        choose_content(MiniPick, item)
      end,
    },
  }, local_opts)

  MiniPick.start(opts)
end

return M
