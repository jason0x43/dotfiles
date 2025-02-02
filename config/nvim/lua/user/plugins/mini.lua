---mini.statusline LSPs section
---@param sl any
---@param args table
local function section_lsps(sl, args)
  local clients
  local client_names = {}

  if vim.lsp.get_clients ~= nil then
    clients = vim.lsp.get_clients()
  end

  for _, client in pairs(clients) do
    table.insert(client_names, client.name)
  end

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
local function section_diagnostics(sl, args)
  local section = sl.section_diagnostics(args)
  section = string.gsub(section, '(E%d+)', hl('%1', 'MiniStatuslineError'))
  section = string.gsub(section, '(W%d+)', hl('%1', 'MiniStatuslineWarning'))
  section = string.gsub(section, '(I%d+)', hl('%1', 'MiniStatuslineInfo'))
  section = string.gsub(section, '(H%d+)', hl('%1', 'MiniStatuslineHint'))
  return section
end

local sep = '/'
local width_mult = 0.816

--- Truncate a path
local function truncate_path(path)
  local width = math.floor(width_mult * vim.o.columns) - 4
  print(width)

  if path:len() <= width then
    return path
  end

  local parts = vim.split(path, sep)
  if #parts > 2 then
    parts = { parts[1], '…', parts[#parts] }
  end
  return table.concat(parts, sep)
end

--- Map a gsub over an table of strings
local function map_gsub(items, pattern, replacement)
  return vim.tbl_map(function(item)
    item, _ = string.gsub(item, pattern, replacement)
    return item
  end, items)
end

--- Truncate pathnames
local function truncate(buf_id, items, query, opts)
  items = map_gsub(items, '^%Z+', truncate_path)
  MiniPick.default_show(buf_id, items, query, opts)
end

--- Give a code action title a sort score
---@param title string
local function score_action(title)
  if title:find('^Update dependencies') then
    return 11
  end
  if title:find('^Add import ') then
    return 10
  end
  if title:find('^Import ') then
    return 9
  end
  if title:find('^Update import ') then
    return 8
  end
  if title:find('^Show documentation ') then
    return 4
  end
  if title:find('^Disable ') then
    return 3
  end
  if title:find('^Move to a new file') then
    return 0
  end

  return 5
end

--- Sort code actions by score
---@param a { action: { title: string } }
---@param b { action: { title: string } }
local function sort_actions(a, b)
  if score_action(a.action.title) > score_action(b.action.title) then
    return true
  end
end

-- Get the command to use for the files picker
local function get_files_command()
  return { 'fd', '--follow', '--color=never' }
end

-- Show icons in the file picker
local function show_files_icons(buf_id, items, query)
  MiniPick.default_show(buf_id, items, query, { show_icons = true })
end

-- A mapping of diagnostic severity values to severity name for groups and icons
---@type string[]
local severity_names = { 'Error', 'Warn', 'Info', 'Hint' }

---@param str string
---@param query string[]
---@return integer[] | nil
local function find_matches(str, query)
  local lower_str = str:lower()
  local offset = 0
  ---@type integer[]
  local indexes = {}

  for _, v in ipairs(query) do
    local idx = lower_str:find(v:lower(), offset)
    if idx == nil then
      return nil
    end
    table.insert(indexes, idx)
    offset = idx + 1
  end

  return indexes
end

return {
  -- many things
  {
    'echasnovski/mini.nvim',

    version = false,

    dependencies = { 'glepnir/nerdicons.nvim' },

    config = function()
      -- file tree / explorer
      require('mini.files').setup({
        mappings = {
          go_in_plus = '<CR>',
        },
      })
      vim.keymap.set('n', '<leader>n', function()
        if vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1 then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        else
          MiniFiles.open()
        end
      end)

      -- pickers
      require('mini.extra').setup()
      require('mini.pick').setup({
        mappings = {
          paste = '',
          refine = '<C-r>',
        },
        window = {
          config = { width = math.floor(width_mult * vim.o.columns) },
        },
      })

      -- Pick from files *and* directories
      MiniPick.registry.files_and_dirs = function(local_opts)
        local source = {
          name = string.format('Files and dirs'),
          show = show_files_icons,
          choose = function(item)
            vim.schedule(function()
              MiniPick.default_choose(item)
            end)
          end,
        }
        if local_opts['cwd'] then
          source['cwd'] = local_opts['cwd']
          source['name'] = source['name'] .. ' (' .. local_opts['cwd'] .. ')'
        end
        return MiniPick.builtin.cli(
          { command = get_files_command() },
          { source = source }
        )
      end

      -- Filter some entries out of oldfiles
      MiniPick.registry.oldfiles = function(local_opts)
        vim.v.oldfiles = vim.tbl_filter(function(item)
          return not vim.endswith(item, 'COMMIT_EDITMSG')
        end, vim.v.oldfiles)
        return MiniExtra.pickers.oldfiles(local_opts)
      end

      -- Better diagnostic formatting
      MiniPick.registry.diagnostic = function(local_opts)
        local single_file = local_opts and local_opts.scope == 'current'
          or false

        return MiniExtra.pickers.diagnostic(local_opts, {
          source = {
            show = function(buf_id, items_to_show, query)
              ---@type string[]
              local lines = {}
              ---@type { hlgroup: string, line: number, col_start: integer, col_end: integer }[]
              local highlights = {}

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
                vim.api.nvim_buf_add_highlight(
                  buf_id,
                  -1,
                  v.hlgroup,
                  v.line,
                  v.col_start,
                  v.col_end
                )
              end
            end,

            ---@param buf_id number
            ---@param item vim.Diagnostic
            preview = function(buf_id, item)
              local message = item.message
              local severity = item.severity
              local hl_group = 'Diagnostic' .. severity_names[severity]
              local text = message
              local source = item.source
                .. (item.code and ': ' .. item.code or '')

              vim.api.nvim_set_option_value('wrap', true, {})
              vim.api.nvim_set_option_value('linebreak', true, {})
              vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { text, source })
              vim.api.nvim_buf_add_highlight(buf_id, -1, hl_group, 0, 0, -1)
              vim.api.nvim_buf_add_highlight(
                buf_id,
                -1,
                'DiagnosticVirtualTextHint',
                1,
                0,
                -1
              )
            end,
          },
        })
      end

      ---@param items table
      ---@param opts table
      ---@param on_choice function?
      local ui_select = function(items, opts, on_choice)
        local type = opts.prompt or opts.kind
        if type:find('Code actions') then
          table.sort(items, sort_actions)
        end
        return MiniPick.ui_select(items, opts, on_choice)
      end
      vim.ui.select = ui_select

      -- files
      vim.keymap.set('n', '<leader>f', function()
        MiniPick.registry.files_and_dirs({})
      end)

      -- live grep
      vim.keymap.set('n', '<leader>g', function()
        MiniPick.builtin.grep_live({}, {
          source = { show = truncate },
        })
      end)

      -- diagnostics
      vim.keymap.set('n', '<leader>d', function()
        MiniPick.registry.diagnostic({ scope = 'current' })
      end)
      vim.keymap.set('n', '<leader>s', function()
        MiniPick.registry.diagnostic({})
      end)

      -- buffers
      vim.keymap.set('n', '<leader>b', function()
        MiniPick.builtin.buffers()
      end)

      -- recent
      vim.keymap.set('n', '<leader>o', function()
        MiniPick.registry.oldfiles()
      end)

      -- help
      vim.keymap.set('n', '<leader>h', function()
        MiniPick.builtin.help()
      end)

      -- modified git files
      vim.keymap.set('n', '<leader>m', function()
        MiniExtra.pickers.git_files({ scope = 'modified' })
      end)

      -- ls references
      vim.keymap.set('n', '<leader>lr', function()
        MiniExtra.pickers.lsp({ scope = 'references' })
      end)

      -- recently visited paths
      vim.keymap.set('n', '<leader>p', function()
        MiniExtra.pickers.visit_paths()
      end)

      vim.api.nvim_create_user_command('Hlgroups', function()
        MiniExtra.pickers.hl_groups()
      end, {})

      vim.api.nvim_create_user_command('Icons', function()
        MiniPick.start({
          source = {
            items = function()
              local icons = require('nerdicons.icons').get_icons()
              local items = {}
              for k, v in pairs(icons) do
                table.insert(items, { text = v .. '  ' .. k, icon = v })
              end
              return items
            end,
            choose = function(item)
              vim.schedule(function()
                vim.api.nvim_put({ item['icon'] }, '', false, true)
              end)
            end,
          },
        })
      end, {})

      -- buffer deletion
      require('mini.bufremove').setup()
      vim.keymap.set('n', '<leader>k', function()
        MiniBufremove.delete()
      end)
      vim.keymap.set('n', '<leader>K', function()
        MiniBufremove.wipeout()
      end)

      -- animated indent line
      require('mini.indentscope').setup()

      -- status line
      local sl = require('mini.statusline')
      sl.setup({
        content = {
          active = function()
            local mode, mode_hl = sl.section_mode({ trunc_width = 120 })
            local git = sl.section_git({ trunc_width = 75 })
            local diagnostics = section_diagnostics(sl, { trunc_width = 75 })
            local filename = sl.section_filename({ trunc_width = 140 })
            local location = sl.section_location({ trunc_width = 140 })
            local lsps = section_lsps(sl, { trunc_width = 140 })

            return sl.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevInfo', strings = { git, diagnostics } },
              '%<', -- begin left alignment
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- end left alignment
              { hl = 'MiniStatuslineDevInfo', strings = { lsps } },
              { hl = mode_hl, strings = { location } },
            })
          end,
          inactive = function()
            local filename = sl.section_filename({})
            return sl.combine_groups({
              { hl = 'MiniStatuslineFilename', strings = { filename } },
            })
          end,
        },
      })

      -- surround
      require('mini.surround').setup()

      -- bracket movement
      require('mini.bracketed').setup()

      -- jumping around
      require('mini.jump2d').setup()

      -- location and label tracking
      require('mini.visits').setup()

      -- diffing
      require('mini.diff').setup()
      vim.api.nvim_create_user_command('Diff', function()
        MiniDiff.toggle_overlay(0)
      end, {})

      -- icons
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
}
