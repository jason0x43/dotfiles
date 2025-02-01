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

-- Get the tool to use for the files picker
local get_files_tool = function()
  if vim.fn.executable('fd') == 1 then
    return 'fd'
  end
  return 'find'
end

-- Get the command to use for the files picker
local get_files_command = function()
  return { 'fd', '--follow', '--color=never' }
end

-- Show icons in the file picker
local show_files_icons = function(buf_id, items, query)
  MiniPick.default_show(buf_id, items, query, { show_icons = true })
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

      -- Change the file picker
      MiniPick.registry.files_and_dirs = function(_, opts)
        local source = {
          name = string.format('Files and directories'),
          show = show_files_icons,
          choose = function(item)
            vim.schedule(function()
              MiniPick.default_choose(item)
            end)
          end,
        }
        opts = vim.tbl_deep_extend('force', { source = source }, opts or {})
        return MiniPick.builtin.cli({ command = get_files_command() }, opts)
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
        MiniPick.registry.files_and_dirs()
      end)

      -- live grep
      vim.keymap.set('n', '<leader>g', function()
        MiniPick.builtin.grep_live({}, {
          source = { show = truncate },
        })
      end)

      -- diagnostics
      vim.keymap.set('n', '<leader>d', function()
        MiniExtra.pickers.diagnostic({
          scope = 'current',
        }, {
          source = {
            preview = function(buf_id, item)
              print(vim.inspect(item))
              local message = item.message
              local source = item.source
              local code = item.code
              local severity = item.severity

              local text = message
              if code or source then
                  text = text .. ' ['
                  if code and source then
                    text = text .. code .. ', ' .. source
                  elseif code then
                    text = text .. code
                  else
                    text = text .. source
                  end
                  text = text .. ']'
              end

              local hl_group = 'DiagnosticError'
              if severity == 'warning' then
                hl_group = 'DiagnosticWarning'
              elseif severity == 'info' then
                hl_group = 'DiagnosticInfo'
              end

              vim.api.nvim_set_option_value('wrap', true, {})
              vim.api.nvim_set_option_value('linebreak', true, {})
              vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { text })
              vim.api.nvim_buf_add_highlight(
                buf_id,
                -1,
                hl_group,
                0,
                0,
                #message
              )
              vim.api.nvim_buf_add_highlight(
                buf_id,
                -1,
                'DiagnosticVirtualTextHint',
                0,
                #message + 1,
                -1
              )
            end
          },
        })
      end)

      -- buffers
      vim.keymap.set('n', '<leader>b', function()
        MiniPick.registry.buffers({}, {})
      end)

      -- recent
      vim.keymap.set('n', '<leader>r', function()
        MiniPick.registry.oldfiles({}, {})
      end)

      -- help
      vim.keymap.set('n', '<leader>h', function()
        MiniPick.registry.help()
      end)

      -- modified git files
      vim.keymap.set('n', '<leader>m', function()
        MiniPick.registry.git_files({ scope = 'modified' })
      end)

      -- ls references
      vim.keymap.set('n', '<leader>lr', function()
        MiniPick.registry.lsp({ scope = 'references' })
      end)

      -- recently visited files
      vim.keymap.set('n', '<leader>vp', function()
        MiniPick.registry.visit_paths()
      end)

      -- recently visited labels
      vim.keymap.set('n', '<leader>vl', function()
        MiniPick.registry.visit_labels()
      end)

      vim.api.nvim_create_user_command('Hlgroups', function()
        MiniPick.registry.hl_groups()
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

      -- icons
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
}
