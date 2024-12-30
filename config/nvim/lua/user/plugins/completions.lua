return {
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    opts = {
      sources = {
        -- TODO: use this on next version update
        default = { 'lsp', 'copilot', 'path', 'buffer', 'lazydev' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            fallbacks = { 'lsp' },
          },
        },
      },
      signature = { enabled = true },
      keymap = {
        preset = 'default',
        ['<C-e>'] = { 'select_and_accept' },
        -- cmdline = {
        --   preset = 'enter',
        --   -- ['<Tab>'] = { 'select_next', 'fallback' },
        --   -- ['<S-Tab>'] = { 'select_prev', 'fallback' },
        -- },
      },
    },
  },

  {
    'giuxtaposition/blink-cmp-copilot',
    dependencies = 'zbirenbaum/copilot.lua',
  },
}
