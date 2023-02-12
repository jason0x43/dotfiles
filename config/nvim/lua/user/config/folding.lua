local M = {}

M.foldtext = function()
	local indentation = vim.fn.indent(vim.v.foldstart)
	local text = ''
	for i = 1, indentation do
		text = text .. ' '
	end
	local foldSize = 1 + vim.v.foldend - vim.v.foldstart

	return text .. foldSize .. " lines"

	-- return vim.fn.repeat("", indentation) .. "fold"
	-- local foldSize = 1 + vim.v.foldend - vim.v.foldstart
	-- local foldSizeStr = " " .. foldSize .. " lines "
	-- local foldLevelStr = vim.fn.repeat('+--', vim.v.foldlevel)
	-- local expansionString = vim.fn.repeat(" ", indentation)
	-- return expansionString .. foldLevelStr .. foldSizeStr
end

return M
