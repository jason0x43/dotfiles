if vim.fn.executable('tig') == 1 then
  vim.api.nvim_create_user_command('Tig', function()
    require('snacks').terminal('tig', {
      win = {
        border = 'rounded',
      },
    })
  end, { desc = 'Open tig' })
end

vim.api.nvim_create_user_command('Autocommands', function()
  require('snacks').picker.autocmds()
end, { desc = 'List configured autocommands' })

vim.api.nvim_create_user_command('Commands', function()
  require('snacks').picker.commands()
end, { desc = 'List configured user commands' })

vim.api.nvim_create_user_command('Config', function()
  require('snacks').picker.explorer({ cwd = '~/.config' })
end, { desc = 'Open an explorer in the config directory' })

vim.api.nvim_create_user_command('Highlights', function()
  require('snacks').picker.highlights()
end, { desc = 'List highlight groups' })

vim.api.nvim_create_user_command('Icons', function()
  require('snacks').picker.icons()
end, { desc = 'List available icons' })

vim.api.nvim_create_user_command('Keys', function()
  require('snacks').picker.keymaps()
end, { desc = 'List configured keymaps' })

vim.api.nvim_create_user_command('Lsps', function()
  require('snacks').picker.lsp_config()
end, { desc = 'List known language servers' })

vim.api.nvim_create_user_command('Notifications', function()
  require('snacks').notifier.show_history()
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
