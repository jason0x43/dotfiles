---@param name string
---@param callback string | fun(args: vim.api.keyset.create_user_command.command_args)
---@param desc string
---@param nargs string|number|nil
local cmd = function(name, callback, desc, nargs)
  vim.api.nvim_create_user_command(
    name,
    callback,
    { desc = desc, nargs = nargs }
  )
end

cmd('Commands', 'Pick commands', 'List configured user commands')

cmd(
  'Config',
  'lua MiniFiles.open("~/.config")',
  'Open an explorer in the config directory'
)

cmd('Highlights', 'Pick hl_groups', 'List highlight groups')

cmd('Icons', 'Pick icons', 'List available icons')

cmd('Keys', 'Pick keymaps', 'List configured keymaps')

cmd('Map', 'lua require("mini.map").toggle()', 'Show or hide a file map')

cmd('Modified', 'Pick modified', 'List modified git files')

cmd(
  'Notifications',
  'lua MiniNotify.show_history()',
  'Show a list of displayed notifications'
)

cmd('Recent', 'Pick recent', 'Find recent files')

cmd('Diff', 'MiniDiff.toggle_overlay(0)', 'Toggle a git diff overlay', '?')

cmd('KittyFocus', function(arg)
  require('user.terminal').focus_kitty(arg.args)
end, 'Move the window focus', 1)

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

cmd(
  'CommitMessage',
  function()
    vim.notify('Generating commit message...', vim.log.levels.INFO)

    -- Run opencode command and capture output directly
    vim.system(
      { 'opencode', 'run', '--command', 'commit-message' },
      { text = true },
      function(result)
        vim.schedule(function()
          if result.code ~= 0 then
            vim.notify(
              'Failed to generate commit message: ' .. (result.stderr or ''),
              vim.log.levels.ERROR
            )
            return
          end

          local output = result.stdout or ''
          if output == '' then
            vim.notify(
              'No commit message generated',
              vim.log.levels.WARN
            )
            return
          end

          -- Split output into lines
          local lines = vim.split(output, '\n', { plain = true })

          -- Remove trailing empty line if present
          if lines[#lines] == '' then
            table.remove(lines)
          end

          if #lines == 0 then
            vim.notify(
              'No commit message generated',
              vim.log.levels.WARN
            )
            return
          end

          -- Insert the commit message at cursor position
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local row = cursor_pos[1] - 1 -- 0-indexed for nvim_buf_set_lines

          vim.api.nvim_buf_set_lines(0, row, row, false, lines)
        end)
      end
    )
  end,
  'Generate a commit message for the currently staged changes'
)
