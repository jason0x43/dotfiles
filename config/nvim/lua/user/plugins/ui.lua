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
        end
      })
    end,
  },

  -- Better UI
  'stevearc/dressing.nvim',

  -- Popup notifications
  {
    'rcarriga/nvim-notify',

    opts = function()
      vim.notify = require('notify')
      if vim.go.termguicolors then
        return {
          timeout = 1000,
        }
      end

      return {
        timeout = 3000,
        stages = 'static',
      }
    end,
  },

  -- highlight current word
  {
    'tzachar/local-highlight.nvim',
    opts = function()
      vim.api.nvim_set_hl(0, 'LocalHighlight', { link = 'CursorLine' })
      return {
        cw_hlgroup = 'LocalHighlight',
      }
    end,
  },
}
