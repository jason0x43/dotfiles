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

-- Build a "rank" table from visits (lower is better).
---@return { [string]: number } ranks a mapping of paths to ranks
local function build_visits_rank()
  local visit_paths = require('mini.visits').list_paths() or {}
  ---@type { [string]: number }
  local rank = {}
  for i, p in ipairs(visit_paths) do
    -- Save both relative-to-project and absolute keys (be generous)
    rank[vim.fn.fnamemodify(p, ':.')] = i
    rank[vim.fn.fnamemodify(p, ':p')] = i
  end
  return rank
end

---Subsequence match; returns positions of matched runs of chars (or nil if no match)
---@param s string The string to search in
---@param q string The query to match
---@return { [number]: number } | nil pos a mapping of positions to match lengths
local function subseq_positions(s, q)
  local i = 1
  local j = 1
  local pos = {}
  local cur_len = 0

  while i <= #s and j <= #q do
    if s:sub(i, i) == q:sub(j, j) then
      cur_len = (i > 1 and pos[i - 1] or 0) + 1
      pos[i] = cur_len
      j = j + 1
    else
      cur_len = 0
    end
    i = i + 1
  end

  if j <= #q then
    return nil
  end

  return pos
end

-- Fuzzy score emphasizing contiguous runs in the BASENAME.
-- Higher is better.
---@param string string The basename to score
---@param query string The query to match against
---@return number score a fuzzy score
local function fuzzy_score(string, query)
  if query == '' then
    return 0
  end

  -- exact match is highest priority
  if string == query then
    return 1e9
  end

  -- starting with a match is next
  if string:sub(1, #query) == query then
    return 5e8
  end

  local matches = subseq_positions(string, query)

  -- non-matching queries are bad
  if not matches then
    return -math.huge
  end

  -- find the longest match
  local longest = 0
  local positions = {}
  for pos, len in pairs(matches) do
    table.insert(positions, pos)

    if longest == 0 then
      longest = pos
    elseif len > matches[longest] then
      longest = pos
    end
  end

  -- compute gaps - how spread out the subsequence is inside the basename
  local span = positions[#positions] - positions[1] + 1
  local gaps = span - #query

  -- boost contiguous runs heavily, then penalize gaps and the number of runs
  return 10000 * longest - 50 * gaps - 50 * #positions
end

---@param stritems string[] List of strings to match against
---@param indices integer[] List of indices to match against
---@param query string[] Query to match
---@param opts { sync?: boolean; preserve_order?: boolean }
local function smart_match(stritems, indices, query, opts)
  local MiniPick = require('mini.pick')

  -- Force sync so default_match returns indices even in async pickers
  opts = vim.tbl_extend('force', {}, opts or {}, { sync = true })

  -- 1) Filter using mini.pick's matcher
  local filtered = MiniPick.default_match(stritems, indices, query, opts) or {}
  if opts.preserve_order or #filtered <= 1 then
    return filtered
  end

  -- 2) Score the filtered subset
  ---@type number[]
  local fname_score = {}
  ---@type string[]
  local rel_paths = {}
  ---@type string[]
  local full_paths = {}
  local query_str = table.concat(query, '')
  for _, f in ipairs(filtered) do
    local basename = vim.fn.fnamemodify(stritems[f], ':t')
    fname_score[f] = fuzzy_score(basename, query_str)
    rel_paths[f] = vim.fn.fnamemodify(stritems[f], ':.')
    full_paths[f] = vim.fn.fnamemodify(stritems[f], ':p')
  end

  local visit_rank = build_visits_rank()
  local INF = math.huge

  -- 3) Sort: fuzzy > frecency > path length > lexicographic
  table.sort(filtered, function(i1, i2)
    local score1 = fname_score[i1] or -math.huge
    local score2 = fname_score[i2] or -math.huge

    if score1 ~= score2 then
      return score1 > score2
    end

    local rel1 = rel_paths[i1]
    local rel2 = rel_paths[i2]
    local r1 = visit_rank[rel1] or visit_rank[full_paths[i1]] or INF
    local r2 = visit_rank[rel2] or visit_rank[full_paths[i2]] or INF

    if r1 ~= r2 then
      return r1 < r2
    end

    if #rel1 ~= #rel2 then
      return #rel1 < #rel2
    end

    return rel1 < rel2
  end)

  return filtered
end

---A 'smart' file picker
M.picker_smart = function(local_opts)
  MiniPick.builtin.files(local_opts, {
    source = {
      name = 'Smart',
      match = smart_match,
    },
  })
end

return M
