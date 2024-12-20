vim.filetype.add({
  filename = {
    ['.envrc'] = 'bash',
    ['.jscsrc'] = 'json',
    ['.bowerrc'] = 'json',
    ['.tslintrc'] = 'json',
    ['.eslintrc'] = 'json',
    ['.dojorc'] = 'json',
    ['.prettierrc'] = 'json',
    Fastfile = 'ruby',
    Podfile = 'ruby',
  },
  pattern = {
    ['*.dashtoc'] = 'json',
    ['[tj]sconfig.json'] = 'jsonc',
    ['Dockerfile.*'] = 'dockerfile',
    ['fish_funced.*'] = 'fish',
    ['*.ejs'] = 'html',
    ['.*/git/config'] = 'gitconfig',
    ['*/zsh/functions/*'] = 'zsh',
    ['.*/ansible/.*%.yml'] = 'yaml.ansible',
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
          or first_line == '#!/usr/bin/env node'
        then
          return 'javascript'
        end

        if first_line:find('#!/usr/bin/env %-S deno') ~= nil then
          return 'typescript'
        end
      end,
    },
  },
})
