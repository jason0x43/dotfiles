return {
  'stevearc/aerial.nvim',

  config = function()
    local aerial = require('aerial')
    aerial.setup({
      close_on_select = true,
      layout = {
        max_width = 0.3,
        width = 30,
      },
    })

    vim.keymap.set('n', '<leader>s', function()
      aerial.toggle({ focus = true })
    end)

    vim.api.nvim_set_hl(0, 'AerialLine', { link = 'CursorLine' })
  end,
}
