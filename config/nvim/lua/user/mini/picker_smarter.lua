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
---@param local_opts table
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
      ---@param show_opts table
      show = function(buf_id, items, query, show_opts)
        show_opts = vim.tbl_extend(
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
