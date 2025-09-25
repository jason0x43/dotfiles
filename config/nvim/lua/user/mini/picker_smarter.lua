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

---@alias Item {
---  text: string;
---  type: 'file' | 'buffer';
---  bufnr?: number;
---  path?: string;
---  is_file: boolean }

---@return Item[]
local function get_file_buffers()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  buffers = vim.tbl_filter(function(buf)
    local buftype = vim.bo[buf.bufnr].buftype

    if buftype == 'quickfix' or buftype == 'prompt' then
      return false
    end

    if buftype == '' then
      if buf.name == '' then
        return true
      end
      return vim.fn.filereadable(buf.name) == 1
    else
      return true
    end
  end, buffers)

  table.sort(buffers, function(a, b)
    return a.lastused > b.lastused
  end)

  return vim.tbl_map(function(buf)
    local buftype = vim.bo[buf.bufnr].buftype
    local is_file = buftype == ''
    local text = is_file and vim.fn.fnamemodify(buf.name, ':.') or buf.name
    return { text = text, bufnr = buf.bufnr, type = 'buffer', is_file = is_file }
  end, buffers)
end

---@param paths string[] List of file paths
---@param buffers Item[] List of buffer names
---@return string[]
local function remove_buffers(paths, buffers)
  ---@type { [string]: boolean }
  local seen = {}

  for _, buf in ipairs(buffers) do
    seen[buf.text] = true
  end

  ---@type string[]
  local deduplicated = {}

  for _, path in ipairs(paths) do
    if path ~= '' then
      path = vim.fn.fnamemodify(path, ':.')
      if not seen[path] then
        table.insert(deduplicated, path)
      end
    end
  end

  table.sort(deduplicated)

  return deduplicated
end

---@param paths string[] List of file paths
---@param items { [string]: Item } A mapping of paths to items
local function add_buffers(paths, items)
  local buffers = get_file_buffers()
  local files = remove_buffers(paths, buffers)

  local all_items = {}

  for _, buf in ipairs(buffers) do
    table.insert(all_items, buf)
    items[buf.text] = buf
  end

  for _, file in ipairs(files) do
    local file_item = {
      type = 'file',
      text = file,
      path = file,
      is_file = true,
    }
    table.insert(all_items, file_item)
    items[file] = file_item
  end

  return all_items
end

---Custom matching function with scoring
---@param stritems string[] List of item texts
---@param indexes integer[] List of indexes to match
---@param query string[] Query segments
---@param items table Table with item metadata
local function match_items(stritems, indexes, query, items)
  -- Safety checks
  if #stritems == 0 or #indexes == 0 then
    return indexes
  end

  -- Empty query: return all items using default behavior
  if not query or #query == 0 then
    return MiniPick.default_match(stritems, indexes, query, { sync = true })
  end

  local ok, result = pcall(function()
    -- Get items to match (only those in indexes)
    ---@type Item[]
    local items_to_match = {}
    ---@type { [number]: number }
    local idx_map = {} -- Map result index to original index

    for _, idx in ipairs(indexes) do
      table.insert(items_to_match, stritems[idx])
      idx_map[#items_to_match] = idx
    end

    -- Use matchfuzzypos for fuzzy matching
    local match_result = vim.fn.matchfuzzypos(items_to_match, query[1])
    local matched_texts = match_result[1]
    local scores = match_result[3]

    -- If no texts matched, return an empty list
    if #matched_texts == 0 then
      return {}
    end

    -- Build scored items with our custom boosts
    ---@type { idx: number, score: number }[]
    local scored_items = {}

    for i, text in ipairs(matched_texts) do
      ---@type number | nil
      local orig_idx = nil

      -- Find original index by matching text
      for j, item in ipairs(items_to_match) do
        if item == text then
          orig_idx = idx_map[j]
          -- Remove from idx_map to handle duplicates
          idx_map[j] = nil
          break
        end
      end

      if orig_idx then
        local score = scores[i]
        local meta = items.items[text]

        -- Apply boosts (higher score is better for matchfuzzypos)
        if meta and meta.type == 'buffer' then
          -- Double score for buffers
          score = score * 2
        end

        -- Check filename match boost
        local filename = vim.fs.basename(text)
        local filename_result = vim.fn.matchfuzzypos({ filename }, query[1])
        if #filename_result[1] > 0 then
          -- Triple score for filename matches
          score = score * 3
        end

        -- Todo: frecency boost

        table.insert(scored_items, { idx = orig_idx, score = score })
      end
    end

    -- Sort by score (higher is better for matchfuzzypos)
    table.sort(scored_items, function(a, b)
      if math.abs(a.score - b.score) < 0.001 then
        -- Tiebreaker: original order
        return a.idx < b.idx
      end
      return a.score > b.score -- Higher score first
    end)

    -- Return sorted indices
    return vim.tbl_map(function(item)
      return item.idx
    end, scored_items)
  end)

  if ok then
    return result
  end

  -- Fallback to default matching if anything goes wrong
  return MiniPick.default_match(stritems, indexes, query, { sync = true })
end

---A 'smart' file picker
return function(local_opts)
  ---@type { [string]: Item }
  local item_map = {}

  local opts = vim.tbl_extend('force', {}, local_opts or {}, {
    command = {
      'sh',
      '-c',
      'fd --hidden --type f',
    },
    postprocess = function(paths)
      return add_buffers(paths, item_map)
    end,
  })

  MiniPick.builtin.cli(opts, {
    source = {
      name = 'Smarter',
      choose = function(item)
        MiniPick.default_choose(item)
      end,
      ---@param buf_id number
      ---@param items Item[]
      ---@param query string[]
      ---@param opts table
      show = function(buf_id, items, query, opts)
        local show_opts = vim.tbl_extend(
          'force',
          {},
          opts or {},
          { show_icons = true }
        )
        return MiniPick.default_show(buf_id, items, query, show_opts)
      end,
      ---@param stritems string[]
      ---@param inds integer[]
      ---@param query string[]
      match = function(stritems, inds, query)
        return match_items(stritems, inds, query, item_map)
      end,
    },
  })
end
