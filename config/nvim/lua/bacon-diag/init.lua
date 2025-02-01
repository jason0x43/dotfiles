-- Resolve a project-local path to an absolute path
local function resolve(path)
  if path[0] == '/' then
    return path
  end

  return vim.fs.joinpath(vim.fn.getcwd(), path)
end

-- Split a string at a delimiter
local function split(str, delim)
  local result = {}
  local start = 1
  local delim_start, delim_end = str:find(delim, start)

  while delim_start do
    table.insert(result, str:sub(start, delim_start - 1))
    start = delim_end + 1
    delim_start, delim_end = str:find(delim, start)
  end

  table.insert(result, str:sub(start))
  return result
end

-- A mapping of absolute file paths to lists of diagnostics
local file_diags = {}

-- The namespace for bacon diags
local namespace = vim.api.nvim_create_namespace('bacon-diag')

-- A mapping of bacon levels to vim diagnostic severities
local level_severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  help = vim.diagnostic.severity.HINT,
  note = vim.diagnostic.severity.INFO,
}

-- Show diagnostics for the current file
local function show_diagnostics()
  local current_file = vim.fn.expand('%:p')
  if file_diags[current_file] then
    vim.diagnostic.set(namespace, 0, file_diags[current_file])
  end
end

-- Update diagnostics from the bacon locations file
local function update_diagnostics(file)
  vim.diagnostic.reset(namespace, 0)
  file_diags = {}

  local diags = vim.fn.readfile(file)
  local reset_files = {}
  local seen_lines = {}

  for _, line in ipairs(diags) do
    if seen_lines[line] then
      goto continue
    end
    seen_lines[line] = true

    local level, path, line_start, line_end, col_start, col_end, message =
      unpack(split(line, '|:|'))
    if path == nil then
      goto continue
    end

    path = resolve(path)

    if reset_files[path] == nil then
      reset_files[path] = true
      file_diags[path] = {}
    end

    table.insert(file_diags[path], {
      lnum = line_start - 1,
      col = col_start - 1,
      end_lnum = line_end - 1,
      end_col = col_end - 1,
      severity = level_severities[level],
      message = message,
    })

    ::continue::
  end

  show_diagnostics()
end

-- Watch the bacon locations file for changes
local function watch_locations_file(file)
  local w = vim.uv.new_fs_event()
  if w == nil then
    print('Unable to create file watcher')
    return
  end

  local function watch_file(_) end

  local function on_change()
    update_diagnostics(file)
    w:stop()
    watch_file(file)
  end

  watch_file = function()
    w:start(file, {}, vim.schedule_wrap(on_change))
  end

  watch_file()
end

local M = {}

M.setup = function()
  local bacon_locs = vim.fn.findfile('.bacon-locations', '.;')
  if bacon_locs == '' then
    return
  end

  update_diagnostics(bacon_locs)
  watch_locations_file(bacon_locs)

  -- TODO: start per-project watchers with local state

  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
    pattern = '*.rs',
    callback = function()
      show_diagnostics()
    end,
  })
end

return M
