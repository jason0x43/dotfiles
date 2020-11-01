if exists('g:did_coc_loaded')
  runtime! init-coc.vim
elseif has('nvim-0.5')
  runtime! init-lsp.vim
  lua require("completion_config")
endif

UpdateColors
