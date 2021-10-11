local status, selenized = pcall(require, 'colors.selenized')
if status == false then
  print('Unable to load selenized theme')
else
  local theme_file = os.getenv('HOME') .. '/.theme'
  if vim.fn.filereadable(theme_file) == 1 then
    local lines = vim.fn.readfile(theme_file)
    local theme_name = vim.fn.trim(lines[1])
    selenized.apply_theme(theme_name)
  else
    selenized.apply_theme('black')
  end

end
