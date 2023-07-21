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

return {
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
    local eslint_config = find_file(file_dir, function(path)
      local name = vim.fs.basename(path)
      if
        name
        and (
          name:find('.eslintrc', 1, true) == 1
          or name:find('eslint.config.', 1, true) == 1
        )
      then
        return true
      end

      if name == 'package.json' then
        local text = vim.fn.readfile(path)
        local ok, parsed = pcall(vim.fn.json_decode, text)
        if ok and parsed then
          return parsed.eslintConfig ~= nil
        end
      end
    end)
    if eslint_config then
      return vim.fs.dirname(eslint_config)
    end
  end,
}
