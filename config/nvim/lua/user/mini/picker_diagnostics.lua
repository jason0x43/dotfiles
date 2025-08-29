local severity_names = { 'Error', 'Warn', 'Info', 'Hint' }

---A diagnostic picker using a custom format
return function(local_opts)
  local single_file = local_opts and local_opts.scope == 'current' or false
  return MiniExtra.pickers.diagnostic(local_opts, {
    source = {
      show = function(buf_id, items_to_show, query)
        ---@type string[]
        local lines = {}
        ---@type { hlgroup: string, line: number, col_start: integer, col_end: integer }[]
        local highlights = {}

        local function find_matches(str, fquery)
          local lower_str = str:lower()
          local offset = 0
          ---@type integer[]
          local indexes = {}

          for _, v in ipairs(fquery) do
            local idx = lower_str:find(v:lower(), offset)
            if idx == nil then
              return nil
            end
            table.insert(indexes, idx)
            offset = idx + 1
          end

          return indexes
        end

        local hl_ns = vim.api.nvim_create_namespace('picker_diag')

        for _, v in ipairs(items_to_show) do
          local icon = vim.diagnostic.config().signs.text[v.severity]
          local text = v.message:gsub('\n', ' ')
          local line

          if single_file then
            line = string.format('%s │ %s', icon, text)
          else
            line = string.format('%s │ %s │ %s', icon, v.path, text)
          end

          local matches = find_matches(line, query)
          if matches ~= nil then
            local line_num = #lines
            table.insert(lines, line)
            table.insert(highlights, {
              hlgroup = 'Diagnostic' .. severity_names[v.severity],
              line = line_num,
              col_start = 0,
              col_end = #line,
            })
            for _, m in ipairs(matches) do
              table.insert(highlights, {
                hlgroup = 'MiniPickMatchRanges',
                line = line_num,
                col_start = m - 1,
                col_end = m,
              })
            end
          end
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

        for _, v in ipairs(highlights) do
          vim.hl.range(
            buf_id,
            hl_ns,
            v.hlgroup,
            { v.line, v.col_start },
            { v.line, v.col_end }
          )
        end
      end,
    },
  })
end
