local M = {}

---@alias Item {
---  text: string;
---  type: 'file' | 'buffer';
---  bufnr?: number;
---  path?: string;
---  is_file: boolean }

---@alias FilePickerOpts {
---  command: string[],
---  postprocess?: fun (lines: string[]): Item[]}

---@param name string
---@param opts FilePickerOpts
M.open_file_picker = function(name, opts)
  local orig_postprocess = opts.postprocess
  if orig_postprocess ~= nil then
    ---@param lines string[]
    opts.postprocess = function(lines)
      while lines[#lines] == '' do
        lines[#lines] = nil
      end
      return orig_postprocess(lines)
    end
  end

  require('mini.pick').builtin.cli(opts, {
    source = {
      name = name,
      ---@param buf_id number
      ---@param items Item[]
      ---@param query string[]
      ---@param show_opts table
      show = function(buf_id, items, query, show_opts)
        show_opts = vim.tbl_extend(
          'force',
          {},
          show_opts or {},
          { show_icons = true }
        )
        return MiniPick.default_show(buf_id, items, query, show_opts)
      end,
    },
  })
end

---@param local_opts table | nil
---@param picker_opts FilePickerOpts
M.merge_opts = function(local_opts, picker_opts)
  return vim.tbl_extend('force', {}, local_opts or {}, picker_opts)
end
return M
