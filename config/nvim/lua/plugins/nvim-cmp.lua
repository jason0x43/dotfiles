local cmp = require('cmp')
local luasnip = require('luasnip')
local functional = require('plenary.functional')

local function tab_fn(key, snippetfunc, fallback)
  if vim.fn.pumvisible() == 1 then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), 'n')
  elseif luasnip.expand_or_jumpable() then
    vim.fn.feedkeys(
      vim.api.nvim_replace_termcodes(
        '<Plug>luasnip-' .. snippetfunc,
        true,
        true,
        true
      ),
      ''
    )
  else
    fallback()
  end
end

vim.o.completeopt = 'menuone,noselect'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<cr>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<tab>'] = functional.partial(tab_fn, '<c-n>', 'expand-or-jump'),
    ['<s-tab>'] = functional.partial(tab_fn, '<c-p>', 'jump-prev'),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'path' },
    { name = 'buffer' },
  },
})
