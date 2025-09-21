vim.filetype.add({
  filename = {
    Fastfile = 'ruby',
    Podfile = 'ruby',
  },
  extension = {
    ['ejs'] = 'html',
    ['dashtoc'] = 'json',
  },
  pattern = {
    ['appsettings.*.json'] = 'jsonc',
    ['.-/ansible/.-%.yml'] = 'yaml.ansible',
    -- Note: the suggested fallback pattern of [".*"] is never called
    ['.-'] = {
      function()
        -- file content detection
        local first_line = vim.fn.getline(1)

        if first_line == '#!/usr/bin/osascript' then
          return 'applescript'
        end

        if first_line == '#!/usr/bin/env -S uv run --script' then
          return 'python'
        end

        if
          first_line == '#!/usr/bin/osascript -l JavaScript'
          or first_line == '#!/usr/bin/env zx'
          or first_line == '#!/usr/bin/env node'
        then
          return 'javascript'
        end

        if first_line:find('#!/usr/bin/env node') then
          return 'javascript'
        end

        if
          first_line:find('#!/usr/bin/env %-S deno') ~= nil
          or first_line:find('#!/usr/bin/env %-S npx tsx') ~= nil
        then
          return 'typescript'
        end
      end,
      { priority = -math.huge },
    },
  },
})

-- Based on Snacks bigfile
vim.filetype.add({
  pattern = {
    ['.*'] = {
      function(path, buf)
        local big_size = 2 * 1024 * 1024
        local big_line = 300

        if not path or not buf or vim.bo[buf].filetype == 'bigfile' then
          return
        end

        if path ~= vim.api.nvim_buf_get_name(buf) then
          return
        end

        local size = vim.fn.getfsize(path)

        if size <= 0 then
          return
        end

        if size > big_size then
          return 'bigfile'
        end

        local avg_line = size / vim.api.nvim_buf_line_count(buf)
        if avg_line > big_line then
          return 'bigfile'
        end
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('bigfile', { clear = true }),
  pattern = 'bigfile',
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.filetype.match({ buf = buf }) or ''

    vim.api.nvim_buf_call(buf, function()
      if vim.fn.exists(':NoMatchParen') ~= 0 then
        vim.cmd([[NoMatchParen]])
      end
      vim.wo.foldmethod = 'manual'
      vim.wo.statuscolumn = ''
      vim.wo.conceallevel = 0
      vim.b.minianimate_disable = true
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          vim.bo[buf].syntax = ft
        end
      end)
    end)
  end,
})
