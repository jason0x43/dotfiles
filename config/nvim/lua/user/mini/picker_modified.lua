local util = require('user.mini.util')

---@param local_opts? table
return function(local_opts)
  ---@type FilePickerOpts
  local picker_opts = {
    command = { 'git', 'status', '--porcelain', '--untracked-files=no' },
    postprocess = function(lines)
      local items = {}
      for _, line in ipairs(lines) do
        -- path is a line with the first three characters sliced off
        local path = line:sub(4)
        table.insert(items, {
          text = path,
          path = path,
          type = 'file',
        })
      end
      return items
    end,
  }
  local opts = util.merge_opts(local_opts, picker_opts)
  util.open_file_picker('Modified', opts)
end
