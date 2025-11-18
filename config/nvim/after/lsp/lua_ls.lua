local home = os.getenv("HOME")

---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      format = {
        -- disable formatting in favor of stylua
        enable = vim.fn.executable('stylua') == 0,
      },

      workspace = {
        checkThirdParty = false,
        library = {
          home .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
        }
      },

      runtime = {
        pathStrict = true,
      },

      type = {
        checkTableShape = true,
      },
    },
  },
}
