-- bootstrap packer
local install_path = vim.fn.stdpath('data')
  .. '/site/pack/packer/start/packer.nvim'
local packer_exists = vim.fn.isdirectory(install_path) ~= 0

if not packer_exists then
  vim.fn.system({
    'git',
    'clone',
    'git@github.com:wbthomason/packer.nvim',
    install_path,
  })
  vim.cmd('packadd packer.nvim')
  require('packer')
  print('Cloned packer')

  require('plugins')
  vim.cmd('PackerInstall')
end

local util = require('util')

-- recompile the packer config whenever this file is edited
util.augroup(
  'init_packer',
  { 'BufWritePost */lua/plugins/init.lua source <afile> | PackerCompile' }
)

util.cmd('PackerSync', 'lua require("plugins").sync()')
util.cmd('PackerCompile', 'lua require("plugins").compile()')
