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
    ['.-/ansible/.-%.yml'] = 'yaml.ansible',
    -- Note: the suggested fallback pattern of [".*"] is never called
    ['.-'] = {
      function()
        -- file content detection
        local first_line = vim.fn.getline(1)

        if first_line == '#!/usr/bin/osascript' then
          return 'applescript'
        end

        if
          first_line == '#!/usr/bin/osascript -l JavaScript'
          or first_line == '#!/usr/bin/env zx'
          or first_line == '#!/usr/bin/env node'
        then
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
