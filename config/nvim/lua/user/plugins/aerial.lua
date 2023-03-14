return {
  'stevearc/aerial.nvim',

  config = function()
    require('aerial').setup({
      layout = {
				max_width = 0.3,
        width = 30,
      },
    })

    vim.keymap.set('n', '<leader>s', '<cmd>AerialToggle!<cr>')
  end,
}
