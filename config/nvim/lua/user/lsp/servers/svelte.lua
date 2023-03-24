return {
  init_options = {
    svelte = {
      trace = {
        server = 'verbose',
      },
    },
  },

  on_attach = function()
    vim.lsp.set_log_level('trace')
    vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
      vim.lsp.buf.execute_command({
        command = '_svelte.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, {})
  end,
}
