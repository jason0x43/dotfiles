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

---mini.statusline LSPs section
---@param sl any
---@param args table
M.section_lsps = function(sl, args)
  local client_names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))

  if vim.tbl_isempty(client_names) then
    return ''
  end

  local icon = ' '

  if sl.is_truncated(args.trunc_width) then
    client_names = vim.tbl_map(function(item)
      return item:sub(1, 2)
    end, client_names)
  end

  return string.format('%s %s', icon, table.concat(client_names, ','))
end

---hilight a string
---@param string string the string to highlight
---@param group string the highlight group to use
---@param resetGroup? string an optional highlight group to apply at the end
local function hl(string, group, resetGroup)
  local hlStr = string.format('%%%%#%s#%s', group, string)
  if resetGroup then
    hlStr = string.format('%s%%%%#%s#', hlStr, resetGroup)
  end
  return hlStr
end

---mini.statusline diagnostics section
---@param sl any
---@param args table
M.section_diagnostics = function(sl, args)
  local section = sl.section_diagnostics(args)
  section = string.gsub(section, '(E%d+)', hl('%1', 'MiniStatuslineError'))
  section = string.gsub(section, '(W%d+)', hl('%1', 'MiniStatuslineWarning'))
  section = string.gsub(section, '(I%d+)', hl('%1', 'MiniStatuslineInfo'))
  section = string.gsub(section, '(H%d+)', hl('%1', 'MiniStatuslineHint'))
  return section
end

---Modify how git blame output is displayed
---@param data MiniGitEventData
M.show_git_blame = function(data)
  -- Format the blame output
  local str = require('user.util.string')
  local random_rgb = require('user.util.theme').random_rgb
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

local severity_names = { 'Error', 'Warn', 'Info', 'Hint' }

---A diagnostic picker using a custom format
M.picker_diagnostics = function(local_opts)
  local single_file = local_opts and local_opts.scope == 'current' or false
  return MiniExtra.pickers.diagnostic(local_opts, {
    source = {
      show = function(buf_id, items_to_show, query)
        ---@type string[]
        local lines = {}
        ---@type { hlgroup: string, line: number, col_start: integer, col_end: integer }[]
        local highlights = {}

        local function find_matches(str, fquery)
          local lower_str = str:lower()
          local offset = 0
          ---@type integer[]
          local indexes = {}

          for _, v in ipairs(fquery) do
            local idx = lower_str:find(v:lower(), offset)
            if idx == nil then
              return nil
            end
            table.insert(indexes, idx)
            offset = idx + 1
          end

          return indexes
        end

        local hl_ns = vim.api.nvim_create_namespace('picker_diag')

        for _, v in ipairs(items_to_show) do
          local icon = vim.diagnostic.config().signs.text[v.severity]
          local text = v.message:gsub('\n', ' ')
          local line

          if single_file then
            line = string.format('%s │ %s', icon, text)
          else
            line = string.format('%s │ %s │ %s', icon, v.path, text)
          end

          local matches = find_matches(line, query)
          if matches ~= nil then
            local line_num = #lines
            table.insert(lines, line)
            table.insert(highlights, {
              hlgroup = 'Diagnostic' .. severity_names[v.severity],
              line = line_num,
              col_start = 0,
              col_end = #line,
            })
            for _, m in ipairs(matches) do
              table.insert(highlights, {
                hlgroup = 'MiniPickMatchRanges',
                line = line_num,
                col_start = m - 1,
                col_end = m,
              })
            end
          end
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

        for _, v in ipairs(highlights) do
          vim.hl.range(
            buf_id,
            hl_ns,
            v.hlgroup,
            { v.line, v.col_start },
            { v.line, v.col_end }
          )
        end
      end,
    },
  })
end

---A recent files picker
M.picker_recent = function(local_opts)
  vim.v.oldfiles = vim.tbl_filter(function(item)
    return not vim.endswith(item, 'COMMIT_EDITMSG')
  end, vim.v.oldfiles)
  return require('mini.extra').pickers.oldfiles(local_opts)
end

---A 'frecency' picker
M.picker_frecency = function(local_opts)
  local inf = math.huge
  local paths = MiniVisits.list_paths()

  -- Make paths relative to the current directory
  paths = vim.tbl_map(function(path)
    return vim.fn.fnamemodify(path, ':.')
  end, paths)

  -- Create a path-to-score table. Lower scores are higher priority.
  local path_scores = {}
  for k, v in pairs(paths) do
    path_scores[v:lower()] = k
  end

  -- Deprioritize the current file
  local current_file = vim.fn.expand('%:.')
  if path_scores[current_file] then
    path_scores[current_file] = inf
  end

  MiniPick.builtin.files(nil, {
    source = {
      name = 'Frecency',
      match = function(stritems, indices, query)
        local indexes = MiniPick.default_match(
          stritems,
          indices,
          query,
          { sync = true, preserve_order = true }
        ) or {}

        table.sort(indexes, function(item1, item2)
          local path1 = stritems[item1]
          local path2 = stritems[item2]
          local score1 = path_scores[path1] or inf
          local score2 = path_scores[path2] or inf
          return score1 < score2
        end)

        return indexes
      end,
    },
  })
end

---An icon picker
M.picker_icons = function(local_opts)
  -- todo
end

return M
