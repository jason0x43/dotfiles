return {
  config = {
    on_attach = function()
      vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
        vim.lsp.buf.execute_command({
          command = '_svelte.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(0) },
        })
      end, {})
    end,
  },
}
