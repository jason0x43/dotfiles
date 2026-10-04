---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    local markers = {
      'tailwind.config.ts',
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'uniwind-types.d.ts',
    }
    local postcss_configs = {
      'postcss.config.js',
      'postcss.config.cjs',
      'postcss.config.mjs',
    }

    local dir = vim.fs.dirname(file)
    while dir do
      for _, marker in ipairs(markers) do
        if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
          on_dir(dir)
          return
        end
      end

      for _, config in ipairs(postcss_configs) do
        local path = vim.fs.joinpath(dir, config)
        if vim.uv.fs_stat(path) then
          local handle = io.open(path, 'r')
          if handle then
            local contents = handle:read('*a')
            handle:close()
            if contents and contents:find('@tailwindcss', 1, true) then
              on_dir(dir)
              return
            end
          end
        end
      end

      local parent = vim.fs.dirname(dir)
      dir = parent ~= dir and parent or nil
    end
  end,
}
