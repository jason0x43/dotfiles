local M = {}

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

return M
