return {
  {
    'saghen/blink.cmp',
    version = 'v0.7.6',
    opts = {
      sources = {
        default = { 'lsp', 'copilot', 'path', 'buffer', 'lazydev' },
      },
      signature = { enabled = true },
      keymap = {
        preset = 'default',
        ['<C-e>'] = { 'select_and_accept' },
      }
    },
  },

  {
    'giuxtaposition/blink-cmp-copilot',
    dependencies = 'zbirenbaum/copilot.lua',
  },
}
