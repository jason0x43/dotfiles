if vim.fn.executable('tig') == 1 then
  vim.api.nvim_create_user_command('Tig', function()
    require('snacks').terminal('tig', {
      win = {
        border = 'rounded',
      },
    })
  end, { desc = 'Open tig' })
end
