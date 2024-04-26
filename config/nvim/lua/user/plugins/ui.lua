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
          local bufnr = ev.buf
          if require('user.util').is_large_file(bufnr) then
            return
          end
          require('colorizer').attach_to_buffer(bufnr)
        end,
      })
    end,
  },

  {
    'stevearc/dressing.nvim',
    opts = {
      select = {
        enabled = false,
      },
    },
  },

  {
    'JManch/sunset.nvim',
    lazy = false,
    enabled = function()
      local locfile = vim.fn.expand('~/.config/location.json')
      return vim.fn.filereadable(locfile)
    end,
    opts = function()
      local locfile = vim.fn.expand('~/.config/location.json')
      if vim.fn.filereadable(locfile) == 0 then
        return
      end
      local location = vim.fn.json_decode(vim.fn.join(vim.fn.readfile(locfile)))

      return {
        latitude = location['latitude'],
        longitude = location['longitude'],
      }
    end,
  },
}
