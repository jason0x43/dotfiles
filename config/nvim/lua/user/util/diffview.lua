local M = {}

--- Modify the diff2_horizontal layout to put the modified file in the center
M.patch_layout = function()
  local async = require('diffview.async')
  local Window = require('diffview.scene.window').Window
  local Diff2Hor = require('diffview.scene.layouts.diff_2_hor').Diff2Hor
  local api = vim.api
  local await = async.await

  ---@override
  ---@param self Diff2Hor
  ---@param pivot integer?
  Diff2Hor.create = async.void(function(self, pivot)
    self:create_pre()
    local curwin

    pivot = pivot or self:find_pivot()
    assert(
      api.nvim_win_is_valid(pivot),
      'Layout creation requires a valid window pivot!'
    )

    for _, win in ipairs(self.windows) do
      if win.id ~= pivot then
        win:close(true)
      end
    end

    api.nvim_win_call(pivot, function()
      vim.cmd('aboveleft vsp')
      curwin = api.nvim_get_current_win()

      if self.b then
        self.b:set_id(curwin)
      else
        self.b = Window({ id = curwin })
      end
    end)

    api.nvim_win_call(pivot, function()
      vim.cmd('aboveleft vsp')
      curwin = api.nvim_get_current_win()

      if self.a then
        self.a:set_id(curwin)
      else
        self.a = Window({ id = curwin })
      end
    end)

    api.nvim_win_close(pivot, true)
    self.windows = { self.a, self.b }
    await(self:create_post())
  end)
end

return M
