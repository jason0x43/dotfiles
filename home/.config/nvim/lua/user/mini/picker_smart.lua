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
return function(local_opts)
  MiniPick.builtin.files(local_opts, {
    source = {
      name = 'Smart',
      match = smart_match,
    },
  })
end
