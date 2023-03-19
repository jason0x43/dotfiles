local M = {}

local function open_win(cmd)
  -- Get the current UI
  local ui = vim.api.nvim_list_uis()[1]

  local width = math.floor(0.85 * ui.width)
  local height = math.floor(0.85 * ui.height)

  -- Create a scratch buffer to be displayed in the floating window
  local buf = vim.api.nvim_create_buf(false, true)

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, 1, {
    relative = 'editor',
    width = width,
    height = height,
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
    border = 'rounded',
  })

  -- Open a new terminal instance in the float
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code, _)
      -- If the terminal process exits cleanly, close the float
      if exit_code == 0 then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })

  -- Be immediately interactive
  vim.cmd('startinsert')
end

function M.setup()
  vim.api.nvim_create_user_command('Tig', function(context)
    if context.fargs[1] == 'file' then
      M.open_file()
    elseif context.fargs[1] == 'project' then
      M.open_project()
    else
      M.open_status()
    end
  end, {
    nargs = '*',
    complete = function(arg_lead)
      local cmds = { 'project', 'status' }
      if vim.api.nvim_buf_get_name(0) ~= '' then
        cmds[#cmds + 1] = 'file'
      end

      local completions = {}
      for _, k in ipairs(cmds) do
        if k:find(arg_lead) == 1 then
          completions[#completions + 1] = k
        end
      end

      return completions
    end,
  })
end

function M.open_project()
  open_win('tig')
end

function M.open_file()
  local file = vim.api.nvim_buf_get_name(0)
  open_win('tig ' .. file)
end

function M.open_status()
  open_win('tig status')
end

return M
