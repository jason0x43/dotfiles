local g = vim.g
local util = require('util')

_G.startify = {}
local startify = _G.startify

g.startify_relative_path = 1
g.startify_fortune_use_unicode = 1
g.startify_use_env = 1
g.startify_files_number = 5
g.startify_change_to_dir = 0
g.startify_ascii_header_1 = {
  '                          _         ',
  '   ____  ___  ____ _   __(_)___ ___ ',
  '  / __ \\/ _ \\/ __ \\ | / / / __ `__ \\',
  ' / / / /  __/ /_/ / |/ / / / / / / /',
  '/_/ /_/\\___/\\____/|___/_/_/ /_/ /_/ ',
  ''
}
g.startify_ascii_header_2 = {
  ' ____ ____ ____ ____ ____ ____ ',
  '||n |||e |||o |||v |||i |||m ||',
  '||__|||__|||__|||__|||__|||__||',
  '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
  ''
}
g.startify_custom_header = 'startify#pad(g:startify_ascii_header_2)'

function startify.show_commit(commit)
  vim.cmd('new')
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  vim.bo.filetype = 'git'
  vim.wo.wrap = false
  vim.wo.number = false
  vim.cmd('$read !Git -C "' .. util.project_root .. '" show ' .. commit)
  -- Jump to the first line
  vim.cmd('normal 1G')
  -- Remove the first line, which will be empty
  vim.cmd('normal dd')
  -- No more writes
  vim.b.modifiable = false

  -- q to exit the preview
  util.keys.map('q', ':close<cr>', { buffer = true })
end

local function startify_commit_cmd(index, str)
  local text = vim.fn.matchstr(str, '\\s\\zs.*')
  local commit = vim.fn.matchstr(str, '^\\x\\+')
  return {
    line = text,
    cmd = 'call v:lua.startify.show_commit("' .. commit .. '")'
  }
end

function startify.list_commits()
  -- Don't bother looking for commits if we're not in a git project
  if util.project_root == '' then
    return {}
  end

  local commits = vim.fn.systemlist(
    'git -C "' .. util.project_root ..
      '" log --format=format:"%h %s <%an, %ar>" -n ' .. g.startify_files_number
  )

  return vim.fn.map(commits, startify_commit_cmd)
end

g.startify_lists = {
  { header = { '    MRU ' .. vim.fn.getcwd() }, type = 'dir' },
  { header = { '    MRU' }, type = 'files' },
  { header = { '    Commits' }, type = startify.list_commits }
}

-- open startify
util.keys.lmap('s', ':Startify<cr>')
