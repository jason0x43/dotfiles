if exists('g:did_coc_loaded')
  runtime! init-coc.vim
else
  runtime! init-lsp.vim
  lua require("completion_config")
endif

UpdateColors
