-- These commands are run without a flag to ensure they override whatever values
-- are set by the global json.vim ftplugin, which is overriding jsonc.vim.

-- Set comment (formatting) related options.
vim.bo.commentstring = '//%s'
-- setlocal commentstring=//%s comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

-- Let Vim know how to disable the plug-in.
vim.b.undo_ftplugin = 'setlocal commentstring< comments<'
