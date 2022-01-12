local nvim_tree = require('lualine.extensions.nvim-tree')

local M = {}

M.sections = vim.deepcopy(nvim_tree.sections)

M.filetypes = { 'Outline' }

return M
