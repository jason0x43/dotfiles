return {
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    opts = {
      sources = {
        -- TODO: use this on next version update
        -- default = { 'lsp', 'copilot', 'path', 'buffer', 'lazydev' },
        completion = {
          enabled_providers = { 'lsp', 'copilot', 'path', 'buffer', 'lazydev' },
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
          lsp = {
            fallback_for = { 'lazydev' },
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
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
