return {
  -- highlight color strings
  {
    'norcalli/nvim-colorizer.lua',
    cond = vim.go.termguicolors,
    config = function()
      require('colorizer').setup({}, {
        names = false,
        rgb_fn = true,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function(ev)
          if ev.match == 'bigfile' then
            return
          end
          require('colorizer').attach_to_buffer(ev.buf)
        end,
      })
    end,
  },
}
