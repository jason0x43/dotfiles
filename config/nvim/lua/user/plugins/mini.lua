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

return {
  -- many things
  {
    'echasnovski/mini.nvim',

    version = false,

    dependencies = { 'glepnir/nerdicons.nvim' },

    config = function()
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

      -- jumping around
      require('mini.jump2d').setup()

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
