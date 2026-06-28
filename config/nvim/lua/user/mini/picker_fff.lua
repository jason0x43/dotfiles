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

  local results = fff.content_search(query or '', { max_results = 100 })

  local items = {}
  for _, r in ipairs(results.items) do
    local rpath = r.relative_path or r.path
    table.insert(items, {
      text = string.format(
        '%s|%d|%d|%s',
        rpath,
        r.line_number,
        r.col,
        r.line_content
      ),
      lnum = r.line_number,
      col = r.col,
      path = r.path,
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
  return MiniPick.default_show(buf_id, items, query, show_opts)
end

local M = {}

M.files = function(local_opts)
  local MiniPick = require('mini.pick')

  local opts = vim.tbl_deep_extend('force', {
    source = {
      name = 'fff_files',
      items = find_files,
      match = function(_, _, query)
        MiniPick.set_picker_items(
          find_files(table.concat(query)),
          { do_match = false }
        )
      end,
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
      items = find_content,
      match = function(_, _, query)
        MiniPick.set_picker_items(
          find_content(table.concat(query)),
          { do_match = false }
        )
      end,
      show = show,
    },
  }, local_opts)

  MiniPick.start(opts)
end

return M
