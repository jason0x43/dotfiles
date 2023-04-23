return {
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
