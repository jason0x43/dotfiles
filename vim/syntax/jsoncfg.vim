source $VIMRUNTIME/syntax/json.vim
syn match jsonCfgComment "//.*"
syn match jsonCfgComment "\(/\*\)\|\(\*/\)"
hi def link jsonCfgComment Comment
