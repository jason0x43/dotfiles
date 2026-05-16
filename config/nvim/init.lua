-- Define plugin hooks before the first `vim.pack.add()` call
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind

    if
      name == 'nvim-treesitter' and (kind == 'install' or kind == 'update')
    then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end

    if name == 'blink.cmp' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('blink.cmp')
      end
      require('blink.cmp').build()
    end
  end,
})

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' }, { load = true })

local misc = require('mini.misc')

-- Define a global Config table for data sharing
_G.Config = {
  github = function(repo)
    return 'https://github.com/' .. repo
  end,
  now = function(f)
    misc.safely('now', f)
  end,
  later = function(f)
    vim.schedule(function()
      misc.safely('later', f)
    end)
  end,
}

-- Define an autocmd group and command factory
local gr = vim.api.nvim_create_augroup('custom-config', {})
_G.Config.new_autocmd = function(event, pattern, callback, desc)
  local opts =
    { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

vim.cmd('colorscheme ansi')
