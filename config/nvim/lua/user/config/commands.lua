vim.api.nvim_create_user_command('Commands', function()
  MiniPick.registry.commands()
end, { desc = 'List configured user commands' })

vim.api.nvim_create_user_command('Config', function()
  MiniFiles.open('~/.config')
end, { desc = 'Open an explorer in the config directory' })

vim.api.nvim_create_user_command('Highlights', function()
  MiniPick.registry.hl_groups()
end, { desc = 'List highlight groups' })

vim.api.nvim_create_user_command('Icons', function()
  MiniPick.registry.icons()
end, { desc = 'List available icons' })

vim.api.nvim_create_user_command('Keys', function()
  MiniPick.registry.keymaps()
end, { desc = 'List configured keymaps' })

vim.api.nvim_create_user_command('Map', function()
  require('mini.map').toggle()
end, { desc = 'Show or hide a file map' })

vim.api.nvim_create_user_command('Modified', function()
  MiniPick.registry.modified()
end, { desc = 'List modified git files' })

vim.api.nvim_create_user_command('Notifications', function()
  MiniNotify.show_history()
end, { desc = 'Show a list of displayed notifications' })

vim.api.nvim_create_user_command('Recent', function()
  require('snacks').picker.recent()
end, { desc = 'Find recent files' })

vim.api.nvim_create_user_command('Term', function()
  require('snacks').terminal.open()
end, { desc = 'Open a terminal' })

vim.api.nvim_create_user_command('Dashboard', function()
  require('snacks').dashboard.open()
end, { desc = 'Open the startup screen' })

vim.api.nvim_create_user_command('Help', function()
  require('snacks').picker.help()
end, { desc = 'Search for help pages' })

vim.api.nvim_create_user_command('Diff', function(info)
  if #info.args > 0 then
    vim.cmd('DiffviewOpen ' .. info.args)
  else
    vim.cmd('DiffviewOpen')
  end
end, { desc = 'Toggle a git diff overlay', nargs = '?' })
