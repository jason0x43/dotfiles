return {
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    dependencies = {
      'giuxtaposition/blink-cmp-copilot',
    },
    opts = function()
      local providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            fallbacks = { 'lsp' },
          },
      }
      local default = { 'lsp', 'path', 'buffer', 'lazydev' }

      local ok, _ = pcall(require, 'copilot.api')
      if ok then
        providers.copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
        }
        table.insert(default, 2, 'copilot')
      end

      return {
        sources = {
          default = default,
          cmdline = {},
          providers = providers,
        },
        signature = {
          enabled = true,
          window = {
            border = 'rounded',
          },
        },
        keymap = {
          preset = 'default',
          ['<C-e>'] = { 'select_and_accept' },
        },
      }
    end
  },
}
