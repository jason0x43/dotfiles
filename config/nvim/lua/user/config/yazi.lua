local M = {}

function M.open_yazi()
  if os.getenv('TERM') ~= 'xterm-kitty' then
    vim.notify(
      'Not running under Kitty; overlay unavailable.',
      vim.log.levels.WARN
    )
    return
  end

  -- Neovim RPC socket path / address
  local addr = vim.v.servername

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
    'yazi',
  }, { detach = true })
end

return M
