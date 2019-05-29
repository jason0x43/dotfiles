" vi:syntax=vim

" base16-vim (https://github.com/chriskempson/base16-vim)
" by Chris Kempson (http://chriskempson.com)

" Terminal color definitions
let s:base0 = '00'
let s:base3 = '08'
let s:base5 = '07'
let s:base7 = '15'
let s:base8 = '01'
let s:baseA = '03'
let s:baseB = '02'
let s:baseC = '06'
let s:baseD = '04'
let s:baseE = '05'
let s:base1 = '10'
let s:base2 = '11'
let s:base4 = '12'
let s:base6 = '13'
let s:base9 = '09'
let s:baseF = '14'

" Theme setup
hi clear
syntax reset
let g:colors_name = 'base16'

" Highlighting function
function! s:Base16hi(group, ctermfg, ctermbg, attr)
  if a:ctermfg != ''
    exec 'hi ' . a:group . ' ctermfg=' . a:ctermfg
  endif
  if a:ctermbg != ''
    exec 'hi ' . a:group . ' ctermbg=' . a:ctermbg
  endif
  if a:attr != ''
    exec 'hi ' . a:group . ' cterm=' . a:attr
  endif
endfunction


function! s:hi(group, ctermfg, ctermbg, attr)
  call s:Base16hi(a:group, a:ctermfg, a:ctermbg, a:attr)
endfun

" Vim editor colors
call s:hi('Normal',                     s:base5, '',      '')
call s:hi('Bold',                       '',      '',      'bold')
call s:hi('Debug',                      s:base8, '',      '')
call s:hi('Directory',                  s:baseD, '',      '')
call s:hi('Error',                      s:base8, 'none',  'underline')
call s:hi('ErrorMsg',                   s:base8, 'none',  '')
call s:hi('Exception',                  s:base8, '',      '')
call s:hi('FoldColumn',                 s:baseC, s:base1, '')
call s:hi('Folded',                     s:base3, s:base1, '')
call s:hi('IncSearch',                  s:base1, s:base9, 'none')
call s:hi('Italic',                     '',      '',      'none')
call s:hi('Macro',                      s:base8, '',      '')
call s:hi('MatchParen',                 s:base0, s:baseC, '')
call s:hi('ModeMsg',                    s:baseB, '',      '')
call s:hi('MoreMsg',                    s:baseB, '',      '')
call s:hi('Question',                   s:baseD, '',      '')
call s:hi('Search',                     s:base1, s:baseA, '')
call s:hi('Substitute',                 s:base1, s:baseA, 'none')
call s:hi('SpecialKey',                 s:base3, '',      '')
call s:hi('TooLong',                    s:base8, '',      '')
call s:hi('Underlined',                 s:base8, '',      '')
call s:hi('Visual',                     '',      s:base2, '')
call s:hi('VisualNOS',                  s:base8, '',      '')
call s:hi('WarningMsg',                 s:base8, '',      '')
call s:hi('WildMenu',                   s:base8, '',      '')
call s:hi('Title',                      s:baseD, '',      'none')
call s:hi('Conceal',                    s:baseD, s:base0, '')
call s:hi('Cursor',                     s:base0, s:base5, '')
call s:hi('NonText',                    s:base3, '',      '')
call s:hi('LineNr',                     s:base3, s:base1, '')
call s:hi('SignColumn',                 s:base3, s:base1, '')
call s:hi('StatusLine',                 s:base4, s:base1, 'none')
call s:hi('StatusLineNC',               s:base3, s:base1, 'none')
call s:hi('VertSplit',                  s:base2, s:base2, 'none')
call s:hi('ColorColumn',                '',      s:base1, 'none')
call s:hi('CursorColumn',               '',      s:base1, 'none')
call s:hi('CursorLine',                 '',      s:base1, 'none')
call s:hi('CursorLineNr',               s:base4, s:base1, '')
call s:hi('QuickFixLine',               '',      s:base1, 'none')
call s:hi('PMenu',                      s:base5, s:base1, 'none')
call s:hi('PMenuSel',                   s:base1, s:base5, '')
call s:hi('TabLine',                    s:base3, s:base1, 'none')
call s:hi('TabLineFill',                s:base3, s:base1, 'none')
call s:hi('TabLineSel',                 s:baseB, s:base1, 'none')

" Standard syntax highlighting
call s:hi('Boolean',                    s:base9, '',      '')
call s:hi('Character',                  s:base8, '',      '')
call s:hi('Comment',                    s:base3, '',      'italic')
call s:hi('Conditional',                s:baseE, '',      '')
call s:hi('Constant',                   s:base9, '',      '')
call s:hi('Define',                     s:baseE, '',      'none')
call s:hi('Delimiter',                  s:baseF, '',      '')
call s:hi('Float',                      s:base9, '',      '')
call s:hi('Function',                   s:baseD, '',      '')
call s:hi('Identifier',                 s:base8, '',      'none')
call s:hi('Include',                    s:baseD, '',      '')
call s:hi('Keyword',                    s:baseE, '',      '')
call s:hi('Label',                      s:baseA, '',      '')
call s:hi('Number',                     s:base9, '',      '')
call s:hi('Operator',                   s:base5, '',      'none')
call s:hi('PreProc',                    s:baseA, '',      '')
call s:hi('Repeat',                     s:baseA, '',      '')
call s:hi('Special',                    s:baseC, '',      '')
call s:hi('SpecialChar',                s:baseF, '',      '')
call s:hi('Statement',                  s:base8, '',      '')
call s:hi('StorageClass',               s:baseA, '',      '')
call s:hi('String',                     s:baseB, '',      '')
call s:hi('Structure',                  s:baseE, '',      '')
call s:hi('Tag',                        s:baseA, '',      '')
call s:hi('Todo',                       s:baseA, s:base1, '')
call s:hi('Type',                       s:baseA, '',      'none')
call s:hi('Typedef',                    s:baseA, '',      '')

" C highlighting
call s:hi('cOperator',                  s:baseC, '',      '')
call s:hi('cPreCondit',                 s:baseE, '',      '')

" C# highlighting
call s:hi('csClass',                    s:baseA, '',      '')
call s:hi('csAttribute',                s:baseA, '',      '')
call s:hi('csModifier',                 s:baseE, '',      '')
call s:hi('csType',                     s:base8, '',      '')
call s:hi('csUnspecifiedStatement',     s:baseD, '',      '')
call s:hi('csContextualStatement',      s:baseE, '',      '')
call s:hi('csNewDecleration',           s:base8, '',      '')

" CSS highlighting
call s:hi('cssBraces',                  s:base5, '',      '')
call s:hi('cssClassName',               s:baseE, '',      '')
call s:hi('cssColor',                   s:baseC, '',      '')

" Diff highlighting
call s:hi('DiffAdd',                    s:baseB, s:base1, '')
call s:hi('DiffChange',                 s:base3, s:base1, '')
call s:hi('DiffDelete',                 s:base8, s:base1, '')
call s:hi('DiffText',                   s:baseD, s:base1, '')
call s:hi('DiffAdded',                  s:baseB, s:base0, '')
call s:hi('DiffFile',                   s:base8, s:base0, '')
call s:hi('DiffNewFile',                s:baseB, s:base0, '')
call s:hi('DiffLine',                   s:baseD, s:base0, '')
call s:hi('DiffRemoved',                s:base8, s:base0, '')

" Git highlighting
call s:hi('gitcommitOverflow',          s:base8, '',      '')
call s:hi('gitcommitSummary',           s:baseB, '',      '')
call s:hi('gitcommitComment',           s:base3, '',      '')
call s:hi('gitcommitUntracked',         s:base3, '',      '')
call s:hi('gitcommitDiscarded',         s:base3, '',      '')
call s:hi('gitcommitSelected',          s:base3, '',      '')
call s:hi('gitcommitHeader',            s:baseE, '',      '')
call s:hi('gitcommitSelectedType',      s:baseD, '',      '')
call s:hi('gitcommitUnmergedType',      s:baseD, '',      '')
call s:hi('gitcommitDiscardedType',     s:baseD, '',      '')
call s:hi('gitcommitBranch',            s:base9, '',      'bold')
call s:hi('gitcommitUntrackedFile',     s:baseA, '',      '')
call s:hi('gitcommitUnmergedFile',      s:base8, '',      'bold')
call s:hi('gitcommitDiscardedFile',     s:base8, '',      'bold')
call s:hi('gitcommitSelectedFile',      s:baseB, '',      'bold')

" GitGutter highlighting
call s:hi('GitGutterAdd',               s:baseB, s:base1, '')
call s:hi('GitGutterChange',            s:baseD, s:base1, '')
call s:hi('GitGutterDelete',            s:base8, s:base1, '')
call s:hi('GitGutterChangeDelete',      s:baseE, s:base1, '')

" HTML highlighting
call s:hi('htmlBold',                   s:baseA, '',      '')
call s:hi('htmlItalic',                 s:baseE, '',      '')
call s:hi('htmlEndTag',                 s:base5, '',      '')
call s:hi('htmlTag',                    s:base5, '',      '')

" JavaScript highlighting
call s:hi('javaScript',                 s:base5, '',      '')
call s:hi('javaScriptBraces',           s:base5, '',      '')
call s:hi('javaScriptNumber',           s:base9, '',      '')
" pangloss/vim-javascript highlighting
call s:hi('jsOperator',                 s:baseD, '',      '')
call s:hi('jsStatement',                s:baseE, '',      '')
call s:hi('jsReturn',                   s:baseE, '',      '')
call s:hi('jsThis',                     s:base8, '',      '')
call s:hi('jsClassDefinition',          s:baseA, '',      '')
call s:hi('jsFunction',                 s:baseE, '',      '')
call s:hi('jsFuncName',                 s:baseD, '',      '')
call s:hi('jsFuncCall',                 s:baseD, '',      '')
call s:hi('jsClassFuncName',            s:baseD, '',      '')
call s:hi('jsClassMethodType',          s:baseE, '',      '')
call s:hi('jsRegexpString',             s:baseC, '',      '')
call s:hi('jsGlobalObjects',            s:baseA, '',      '')
call s:hi('jsGlobalNodeObjects',        s:baseA, '',      '')
call s:hi('jsExceptions',               s:baseA, '',      '')
call s:hi('jsBuiltins',                 s:baseA, '',      '')

" Mail highlighting
call s:hi('mailQuoted1',                s:baseA, '',      '')
call s:hi('mailQuoted2',                s:baseB, '',      '')
call s:hi('mailQuoted3',                s:baseE, '',      '')
call s:hi('mailQuoted4',                s:baseC, '',      '')
call s:hi('mailQuoted5',                s:baseD, '',      '')
call s:hi('mailQuoted6',                s:baseA, '',      '')
call s:hi('mailURL',                    s:baseD, '',      '')
call s:hi('mailEmail',                  s:baseD, '',      '')

" Markdown highlighting
call s:hi('markdownCode',               s:baseB, '',      '')
call s:hi('markdownError',              s:base5, s:base0, '')
call s:hi('markdownCodeBlock',          s:baseB, '',      '')
call s:hi('markdownHeadingDelimiter',   s:baseD, '',      '')

" NERDTree highlighting
call s:hi('NERDTreeDirSlash',           s:baseD, '',      '')
call s:hi('NERDTreeExecFile',           s:base5, '',      '')

" PHP highlighting
call s:hi('phpMemberSelector',          s:base5, '',      '')
call s:hi('phpComparison',              s:base5, '',      '')
call s:hi('phpParent',                  s:base5, '',      '')

" Python highlighting
call s:hi('pythonOperator',             s:baseE, '',      '')
call s:hi('pythonRepeat',               s:baseE, '',      '')
call s:hi('pythonInclude',              s:baseE, '',      '')
call s:hi('pythonStatement',            s:baseE, '',      '')

" Ruby highlighting
call s:hi('rubyAttribute',              s:baseD, '',      '')
call s:hi('rubyConstant',               s:baseA, '',      '')
call s:hi('rubyInterpolationDelimiter', s:baseF, '',      '')
call s:hi('rubyRegexp',                 s:baseC, '',      '')
call s:hi('rubySymbol',                 s:baseB, '',      '')
call s:hi('rubyStringDelimiter',        s:baseB, '',      '')

" SASS highlighting
call s:hi('sassidChar',                 s:base8, '',      '')
call s:hi('sassClassChar',              s:base9, '',      '')
call s:hi('sassInclude',                s:baseE, '',      '')
call s:hi('sassMixing',                 s:baseE, '',      '')
call s:hi('sassMixinName',              s:baseD, '',      '')

" Signify highlighting
call s:hi('SignifySignAdd',             s:baseB, s:base1, '')
call s:hi('SignifySignChange',          s:baseD, s:base1, '')
call s:hi('SignifySignDelete',          s:base8, s:base1, '')

" Spelling highlighting
call s:hi('SpellBad',                   s:base8, 'none',  'undercurl')
call s:hi('SpellLocal',                 '',      'none',  'undercurl')
call s:hi('SpellCap',                   '',      'none',  'undercurl')
call s:hi('SpellRare',                  '',      'none',  'undercurl')

" Startify highlighting
call s:hi('StartifyBracket',            s:base3, '',      '')
call s:hi('StartifyFile',               s:base7, '',      '')
call s:hi('StartifyFooter',             s:base3, '',      '')
call s:hi('StartifyHeader',             s:baseB, '',      '')
call s:hi('StartifyNumber',             s:base9, '',      '')
call s:hi('StartifyPath',               s:base3, '',      '')
call s:hi('StartifySection',            s:baseE, '',      '')
call s:hi('StartifySelect',             s:baseC, '',      '')
call s:hi('StartifySlash',              s:base3, '',      '')
call s:hi('StartifySpecial',            s:base3, '',      '')

" Java highlighting
call s:hi('javaOperator',               s:baseD, '',      '')

" ALE
call s:hi('ALEErrorSign',               s:base8, s:base1, 'bold')

" vim-lsp
call s:hi('LspErrorSign',               s:base8, s:base1, 'bold')
call s:hi('LspWarningSign',             s:baseA, s:base1, 'bold')
call s:hi('LspInformationSign',         s:baseB, s:base1, 'bold')
call s:hi('LspHintSign',                s:baseE, s:base1, 'bold')
call s:hi('LspHintText',                s:base3, s:base1, '')

" coc
call s:hi('CocErrorHighlight',          s:base8, '',      'underline')
call s:hi('CocHighlightText',           '',      s:base1, '')
