local M = {}

local function find_file(path, test)
  while path ~= '/' do
    for name, type in vim.fs.dir(path) do
      local filepath = path .. '/' .. name
      if type == 'file' and test(filepath) then
        return filepath
      end
    end
    path = vim.fs.dirname(path)
  end
  return nil
end

M.config = {
  root_dir = function(filename)
    local project_root = vim.fn.system('git rev-parse --show-toplevel')
    if vim.v.shell_error ~= 0 then
      return nil
    end

    -- Trim the trailing newline
    project_root = vim.trim(project_root)

    -- Look for eslint config files using the same logic as eslint
    local file_dir = vim.fs.dirname(filename)

    -- look for eslint config files
    local eslint_config = vim.fs.find(function(name)
      return name:find('.eslintrc.', 1, true) == 1
        or name:find('eslint.config.', 1, true) == 1
    end, {
      path = file_dir,
      type = 'file',
      upward = true,
    })
    if #eslint_config > 0 then
      return project_root
    end

    -- look for package.json files with eslint configs
    local pkg_json_with_eslint = find_file(file_dir, function(path)
      local name = vim.fs.basename(path)
      if name == 'package.json' then
        local text = vim.fn.readfile(path)
        local ok, parsed = pcall(vim.fn.json_decode, text)
        if ok then
          return parsed.eslintConfig ~= nil
        end
      end
    end)
    if pkg_json_with_eslint ~= nil then
      return project_root
    end
  end,
}

return M
