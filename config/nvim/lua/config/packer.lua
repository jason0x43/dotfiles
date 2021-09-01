-- bootstrap packer
local install_path = vim.fn.stdpath('data')
  .. '/site/pack/packer/start/packer.nvim'
local packer_exists = vim.fn.isdirectory(install_path) ~= 0

if not packer_exists then
  vim.fn.system({
    'git',
    'clone',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })

  print('Cloned packer')

  vim.cmd('packadd packer.nvim')
  require('plugins').install()
end

local util = require('util')

-- recompile the packer config whenever the plugin config file is edited
util.augroup(
  'init_packer',
  { 'BufWritePost */lua/plugins/init.lua source <afile> | PackerCompile' }
)

-- setup a couple Packer commands that work before Packer is loaded
util.cmd('PackerSync', 'lua require("plugins").sync()')
util.cmd('PackerCompile', 'lua require("plugins").compile()')
