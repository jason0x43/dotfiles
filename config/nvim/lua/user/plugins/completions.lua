return {
  {
    'hrsh7th/nvim-cmp',

    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
    },

    opts = function()
      vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

      local cmp = require('cmp')

      return {
        mapping = {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-e>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
        },
        sources = {
          { name = 'copilot' },
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'luasnip' },
          { name = 'buffer' },
        },
        preselect = 'none',
      }
    end,
  },

  {
    'zbirenbaum/copilot-cmp',
    config = true,
    dependencies = 'zbirenbaum/copilot.lua',
  },
}
