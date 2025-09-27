-- Based on Snacks icons picker

local NERDFONTS_SETS = {
  cod = 'Codicons',
  dev = 'Devicons',
  fa = 'Font Awesome',
  fae = 'Font Awesome Extension',
  iec = 'IEC Power Symbols',
  linux = 'Font Logos',
  logos = 'Font Logos',
  oct = 'Octicons',
  ple = 'Powerline Extra',
  pom = 'Pomicons',
  seti = 'Seti-UI',
  weather = 'Weather Icons',
  md = 'Material Design Icons',
}

---@alias PickerIcon {
---  icon: string,
---  name: string,
---  source: string,
---  category: string,
---  desc?: string }

---@type table<string, {url: string, v?:number, build: fun(data:table): PickerIcon[]}>
local sources = {
  nerd_fonts = {
    url = 'https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/glyphnames.json',
    v = 4,
    ---@param data table<string, {char:string, code:string}>
    build = function(data)
      ---@type PickerIcon[]
      local ret = {}

      for name, info in pairs(data) do
        if name ~= 'METADATA' then
          local font, icon = name:match('^([%w_]+)%-(.*)$')
          if not font then
            error('Invalid icon name: ' .. name)
          end

          table.insert(ret, {
            name = icon,
            icon = info.char,
            source = 'nerd fonts',
            category = NERDFONTS_SETS[font] or font,
          })
        end
      end

      return ret
    end,
  },
  emoji = {
    url = 'https://raw.githubusercontent.com/muan/unicode-emoji-json/refs/heads/main/data-by-emoji.json',
    v = 4,
    ---@param data table<string, {name:string, slug:string, group:string}>
    build = function(data)
      ---@type PickerIcon[]
      local ret = {}

      for icon, info in pairs(data) do
        table.insert(ret, {
          name = info.name,
          icon = icon,
          source = 'emoji',
          category = info.group,
        })
      end

      return ret
    end,
  },
}

---@param source_name string
---@return PickerIcon[]
local function load(source_name)
  local source = sources[source_name]
  local file = vim.fn.stdpath('cache')
    .. '/picker_icons/'
    .. source_name
    .. '-v'
    .. (source.v or 1)
    .. '.json'
  vim.fn.mkdir(vim.fn.fnamemodify(file, ':h'), 'p')

  if vim.fn.filereadable(file) == 1 then
    local fd = assert(io.open(file, 'r'))
    local data = fd:read('*a')
    fd:close()

    ---@type PickerIcon[]
    return vim.json.decode(data)
  end

  MiniNotify.add('Fetching `' .. source_name .. '` icons')
  if vim.fn.executable('curl') == 0 then
    MiniNotify.add('`curl` is required to fetch icons', 'ERROR')
    return {}
  end

  local out = vim.fn.system({ 'curl', '-s', '-L', source.url })
  if vim.v.shell_error ~= 0 then
    MiniNotify.add(out, 'ERROR')
    return {}
  end

  local icons = source.build(vim.json.decode(out))
  local fd = assert(io.open(file, 'w'))
  fd:write(vim.json.encode(icons))
  fd:close()

  return icons
end

---@param item PickerIcon
local function choose_icon(item)
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- API uses 0-indexed rows
  row = row - 1

  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  local new_line = line:sub(1, col) .. item.icon .. line:sub(col + 1)

  vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
  -- Move cursor after inserted char
  vim.api.nvim_win_set_cursor(0, { row + 1, col + 3 })
end

---An icon picker
return function(local_opts)
  local opts = local_opts or {}
  local icons = {}

  for _, source in ipairs(opts.icon_sources or { 'nerd_fonts', 'emoji' }) do
    vim.list_extend(icons, load(source))
  end

  for _, icon in ipairs(icons) do
    icon.text = icon.icon .. ': ' .. icon.name
  end

  MiniPick.start({
    source = {
      items = icons,
      choose = function(item)
        vim.api.nvim_win_call(
          MiniPick.get_picker_state().windows.target,
          function()
            choose_icon(item)
          end
        )
      end,
    },
  })
end
