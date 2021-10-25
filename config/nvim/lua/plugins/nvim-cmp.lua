local cmp = require('cmp')
local luasnip = require('luasnip')

vim.opt.completeopt = { 'menuone', 'noselect' }

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match('%s')
      == nil
end

cmp.setup({
  experimental = {
    -- use vim's native completion menu, which may avoid the undo breaking
    -- effect of floats (https://github.com/neovim/neovim/issues/11439)
    native_menu = true,
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-e>'] = cmp.mapping.close(),
    ['<c-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
    -- ['<cr>'] = function(fallback)
    --   if cmp.visible() then
    --     vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-y>'))
    --   else
    --     fallback()
    --   end
    -- end,
    -- ['<tab>'] = function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   elseif has_words_before() then
    --     cmp.complete()
    --   else
    --     fallback()
    --   end
    -- end,
    -- ['<s-tab>'] = function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end,
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
})
