-- set the theme based on the value specified in ~/.vimrc_background
local theme_file = os.getenv('HOME') .. '/.vimrc_background'

local function load_theme_name()
  if os.getenv('SSH_CLIENT') then
    local base16_theme = os.getenv('BASE16_THEME')
    if base16_theme then
      return base16_theme
    end
  end

  if vim.fn.filereadable(theme_file) == 1 then
    local lines = vim.fn.readfile(theme_file, '', 1)
    local words = vim.split(lines[1], '%s')
    return vim.fn.trim(words[#words], "'"):sub(8)
  end
end

vim.g.base16_theme = load_theme_name() or 'ashes'

local status, base16 = pcall(require, 'colors.base16')
if status == false then
  print('Unable to load base16 theme')
else
  base16.apply_theme(vim.g.base16_theme)
end
