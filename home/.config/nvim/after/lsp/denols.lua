---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root = require('user.util.lsp').get_deno_root(bufnr)
    if root then
      on_dir(root)
    end
  end,

  init_options = {
    formatter = true,
    lint = true,
    unstable = true,
  },

  workspace_required = false,
}
