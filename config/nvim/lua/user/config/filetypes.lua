vim.filetype.add({
  pattern = {
    ['Dockerfile.*'] = 'dockerfile',
    ['Fastfile'] = 'ruby',
    ['.*/git/config'] = 'gitconfig',

    ['.*'] = {
      priority = -math.huge,
      function()
        -- file content detection
        local first_line = vim.fn.getline(1)

        if first_line == '#!/usr/bin/osascript' then
          return 'applescript'
        end

        if
          first_line == '#!/usr/bin/osascript -l JavaScript'
          or first_line == '#!/usr/bin/env zx'
        then
          return 'javascript'
        end
      end,
    },
  },
})
