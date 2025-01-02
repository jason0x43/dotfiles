return {
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    opts = {
      sources = {
        default = { 'lsp', 'copilot', 'path', 'buffer', 'lazydev' },
        cmdline = {},
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
      },
    },
  },

  {
    'giuxtaposition/blink-cmp-copilot',
    dependencies = 'zbirenbaum/copilot.lua',
  },
}
