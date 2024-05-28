return {
  on_attach = function(client)
    -- disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end,
}

