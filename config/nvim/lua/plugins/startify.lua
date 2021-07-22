local g = vim.g

g.startify_session_persistence = 0
g.startify_relative_path = 1
g.startify_use_env = 1
g.startify_files_number = 5
g.startify_change_to_dir = 0
g.startify_ascii_header = {
  ' ____ ____ ____ ____ ____ ____ ',
  '||n |||e |||o |||v |||i |||m ||',
  '||__|||__|||__|||__|||__|||__||',
  '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
  '',
}
g.startify_custom_header = 'startify#pad(g:startify_ascii_header)'

g.startify_lists = {
  { header = { '   MRU ' .. vim.fn.getcwd() }, type = 'dir' },
  { header = { '   MRU' }, type = 'files' },
}
