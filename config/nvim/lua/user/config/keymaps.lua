local util = require('user.util')

-- go to previous buffer
util.lmap('<leader>', '<C-^>')

-- toggle crosshairs
util.map('#', '', {
	mode = 'n',
	callback = function()
		if vim.wo.cursorline and vim.wo.cursorcolumn then
			vim.wo.cursorline = false
			vim.wo.cursorcolumn = false
		elseif vim.go.cursorline then
			vim.wo.cursorcolumn = true
		else
			vim.wo.cursorline = true
		end
	end
})

-- save the current file
util.lmap('w', '<cmd>w<cr>')
util.lmap('W', '<cmd>w!<cr>')

-- quit vim
util.lmap('q', '<cmd>qall<cr>')
util.lmap('Q', '<cmd>qall!<cr>')

-- close a window
util.lmap('c', '<cmd>close<cr>')

-- show the syntax highlight state of the character under the cursor
util.lmap('hl', '', {
  callback = util.print_syn_group
})

-- space to clear search highlights
util.map('<space>', '<cmd>noh<cr>')

-- yank to and paste from system clipboard
util.lmap('y', '', {
  mode = 'nvo',
  callback = function()
    util.yank(vim.fn.getreg("0"))
  end
})

util.lmap('p', '"*p')

-- disable "Entering Ex mode"
util.map('Q', '<nop>')
