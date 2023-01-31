local M = {}

M.config = {
  root_dir = function(filename)
    local project_root = vim.fn.system('git rev-parse --show-toplevel')
    if vim.v.shell_error ~= 0 then
      return nil
    end

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
    local pkg_json_with_eslint = vim.fs.find(function(name)
			if name == 'package.json' then
				local text = vim.fn.readfile(name)
				local parsed = vim.fn.json_decode(text)
				return parsed.eslintConfig ~= nil
			end
    end, {
      path = file_dir,
      type = 'file',
      upward = true,
    })
    if #pkg_json_with_eslint > 0 then
      return project_root
    end
  end,
}

return M
