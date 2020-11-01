" Use async format to allow multiple formatters to work. `formatting_sync`
" will fail if any of the formatters fail.
command! Format :lua vim.lsp.buf.formatting(nil)<CR>
lua require("lsp_config")
