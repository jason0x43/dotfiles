-- bootstrap packer
local install_path = vim.fn.stdpath('data')
  .. '/site/pack/packer/start/packer.nvim'
local packer_exists = vim.fn.isdirectory(install_path) ~= 0

if not packer_exists then
  vim.fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })

  print('Cloned packer')

  vim.cmd('packadd packer.nvim')
  require('user.plugins').install()
end

-- recompile the packer config whenever the plugin config file is edited
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*/lua/user/plugins/init.lua',
  command = 'source <afile> | PackerCompile'
})
