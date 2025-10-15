---@param name string
---@param callback fun(args: vim.api.keyset.create_user_command.command_args)
---@param desc string
---@param nargs string|number|nil
local cmd = function(name, callback, desc, nargs)
  vim.api.nvim_create_user_command(
    name,
    callback,
    { desc = desc, nargs = nargs }
  )
end

cmd('Commands', function()
  MiniPick.registry.commands()
end, 'List configured user commands')

cmd('Config', function()
  MiniFiles.open('~/.config')
end, 'Open an explorer in the config directory')

cmd('Highlights', function()
  MiniPick.registry.hl_groups()
end, 'List highlight groups')

cmd('Icons', function()
  MiniPick.registry.icons()
end, 'List available icons')

cmd('Keys', function()
  MiniPick.registry.keymaps()
end, 'List configured keymaps')

cmd('Map', function()
  require('mini.map').toggle()
end, 'Show or hide a file map')

cmd('Modified', function()
  MiniPick.registry.modified()
end, 'List modified git files')

cmd('Notifications', function()
  MiniNotify.show_history()
end, 'Show a list of displayed notifications')

cmd('Recent', function()
  require('snacks').picker.recent()
end, 'Find recent files')

cmd('Term', function()
  require('snacks').terminal.open()
end, 'Open a terminal')

cmd('Dashboard', function()
  require('snacks').dashboard.open()
end, 'Open the startup screen')

cmd('Help', function()
  require('snacks').picker.help()
end, 'Search for help pages')

cmd('Diff', function(args)
  if #args.args > 0 then
    vim.cmd('DiffviewOpen ' .. args.args)
  else
    vim.cmd('DiffviewOpen')
  end
end, 'Toggle a git diff overlay', '?')

cmd('Yazi', function()
  if os.getenv('TERM') ~= 'xterm-kitty' then
    vim.notify(
      'Not running under Kitty; overlay unavailable.',
      vim.log.levels.WARN
    )
    return
  end

  -- Neovim RPC socket path / address
  local addr = vim.v.servername

  local path = os.getenv('PATH')

  -- Pass NVIM (or NVIM_LISTEN_ADDRESS) so nvr knows which instance to target
  vim.fn.jobstart({
    'kitty',
    '@',
    'launch',
    '--type=overlay',
    '--cwd',
    vim.fn.getcwd(),
    '--env',
    'NVIM_SERVER=' .. addr,
    '--env',
    'PATH="' .. path .. '"',
    'yazi',
  }, { detach = true })
end, 'Open a yazi pane')
