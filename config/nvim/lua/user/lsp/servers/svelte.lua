return {
  on_attach = function()
    -- vim.lsp.set_log_level('trace')
    vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
      vim.lsp.buf.execute_command({
        command = '_svelte.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, {})
  end,

  capabilities = {
    workspace = {
      -- Completely disable didChangeWatchedFiles; svelte won't start its
      -- fallback file watcher if it sees a non-falsy value for
      -- didChangeWatchedFiles.
      -- svelte-language-server doesn't register file watchers, and it looks
      -- like nvim's implementation is only sending events to registered
			-- watchers (which is the recommendation in the spec
      -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didChangeWatchedFiles)
      didChangeWatchedFiles = false,
    },
  },
}
