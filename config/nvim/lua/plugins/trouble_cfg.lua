local util = require('util')

local trouble_lsp = require('trouble.providers.lsp')
local orig_diags = trouble_lsp.diagnostics

-- replace trouble's LSP diagnostic handler with one that filters out hint
-- diagnostics
trouble_lsp.diagnostics = function(_win, buf, cb, options)
  local filtered_items = {}

  local function filter_items(items)
    for _, item in ipairs(items) do
      if item.severity <= vim.g.lsp_severity_limit then
        table.insert(filtered_items, item)
      end
    end
  end

  if vim.g.lsp_severity_limit then
    orig_diags(_win, buf, filter_items, options)
    cb(filtered_items)
  else
    orig_diags(_win, buf, cb, options)
  end
end

require('trouble').setup({
  action_keys = {
    jump = { '<tab>' },
    jump_close = { '<cr>' },
  },
  auto_close = true
})

util.lmap('e', ':TroubleToggle<cr>')

util.augroup('init_trouble', {
  'FileType Trouble setlocal cursorline',
})
