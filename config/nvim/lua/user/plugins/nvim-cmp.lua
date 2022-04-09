local req = require('user.req')
local cmp = req('cmp')
local luasnip = req('luasnip')

if cmp == nil or luasnip == nil then
  return
end

local M = {}

M.config = function()
  vim.opt.completeopt = { 'menuone', 'noselect' }

  cmp.setup({
    experimental = {
      -- use vim's native completion menu, which may avoid the undo breaking
      -- effect of floats (https://github.com/neovim/neovim/issues/11439)
      native_menu = vim.fn.has('nvim-0.7') ~= 1,
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<C-y>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          -- local copilot_keys = vim.fn['copilot#Accept']()
          -- if copilot_keys ~= "" then
          --   vim.api.nvim_feedkeys(copilot_keys, "i", true)
          -- else
            fallback()
          -- end
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      { name = 'copilot' },
      { name = 'nvim_lua' },
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'luasnip' },
      { name = 'buffer' },
    },
  })
end

return M
