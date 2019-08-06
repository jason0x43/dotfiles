function! colors#base16#createscheme(palette, name)
    " base16-vim (https://github.com/chriskempson/base16-vim)
    " by Chris Kempson (http://chriskempson.com)

    " Color definitions
    let l:base0 = [a:palette['base0']['cterm'], a:palette['base0']['gui']]
    let l:base1 = [a:palette['base1']['cterm'], a:palette['base1']['gui']]
    let l:base2 = [a:palette['base2']['cterm'], a:palette['base2']['gui']]
    let l:base3 = [a:palette['base3']['cterm'], a:palette['base3']['gui']]
    let l:base4 = [a:palette['base4']['cterm'], a:palette['base4']['gui']]
    let l:base5 = [a:palette['base5']['cterm'], a:palette['base5']['gui']]
    let l:base6 = [a:palette['base6']['cterm'], a:palette['base6']['gui']]
    let l:base7 = [a:palette['base7']['cterm'], a:palette['base7']['gui']]
    let l:base8 = [a:palette['base8']['cterm'], a:palette['base8']['gui']]
    let l:base9 = [a:palette['base9']['cterm'], a:palette['base9']['gui']]
    let l:baseA = [a:palette['baseA']['cterm'], a:palette['baseA']['gui']]
    let l:baseB = [a:palette['baseB']['cterm'], a:palette['baseB']['gui']]
    let l:baseC = [a:palette['baseC']['cterm'], a:palette['baseC']['gui']]
    let l:baseD = [a:palette['baseD']['cterm'], a:palette['baseD']['gui']]
    let l:baseE = [a:palette['baseE']['cterm'], a:palette['baseE']['gui']]
    let l:baseF = [a:palette['baseF']['cterm'], a:palette['baseF']['gui']]

    " Neovim terminal
    if has("nvim")
      let g:terminal_color_0  = l:base0[1]
      let g:terminal_color_1  = l:base8[1]
      let g:terminal_color_2  = l:baseB[1]
      let g:terminal_color_3  = l:baseA[1]
      let g:terminal_color_4  = l:baseD[1]
      let g:terminal_color_5  = l:baseE[1]
      let g:terminal_color_6  = l:baseC[1]
      let g:terminal_color_7  = l:base5[1]
      let g:terminal_color_8  = l:base3[1]
      let g:terminal_color_9  = l:base9[1]
      let g:terminal_color_10 = l:base1[1]
      let g:terminal_color_11 = l:base2[1]
      let g:terminal_color_12 = l:base4[1]
      let g:terminal_color_13 = l:base6[1]
      let g:terminal_color_14 = l:baseF[1]
      let g:terminal_color_15 = l:base7[1]

      let g:terminal_color_background = l:base0[1]
      let g:terminal_color_foreground = l:base5[1]
    endif

    " Theme setup
    hi clear
    if exists('syntax_on')
        syntax reset
    endif
    let g:colors_name = a:name

    " Highlighting function
    function! s:base16hi(group, fg, bg, attr)
      if type(a:fg) == v:t_list
        exec 'hi ' . a:group . ' ctermfg=' . a:fg[0] . ' guifg=' . a:fg[1]
      elseif !empty(a:fg)
        exec 'hi ' . a:group . ' ctermfg=' . a:fg . ' guifg=' . a:fg
      endif

      if type(a:bg) == v:t_list
        exec 'hi ' . a:group . ' ctermbg=' . a:bg[0] . ' guibg=' . a:bg[1]
      elseif !empty(a:bg)
        exec 'hi ' . a:group . ' ctermbg=' . a:bg . ' guibg=' . a:bg
      endif

      if !empty(a:attr)
        exec 'hi ' . a:group . ' cterm=' . a:attr . ' gui=' . a:attr
      endif
    endfunction


    function! s:hi(group, ctermfg, ctermbg, attr)
      call s:base16hi(a:group, a:ctermfg, a:ctermbg, a:attr)
    endfun

    " Vim editor colors
    call s:hi('Normal',                     l:base5, '',      '')
    call s:hi('Bold',                       '',      '',      'bold')
    call s:hi('Debug',                      l:base8, '',      '')
    call s:hi('Directory',                  l:baseD, '',      '')
    call s:hi('Error',                      l:base8, 'none',  'underline')
    call s:hi('ErrorMsg',                   l:base8, 'none',  '')
    call s:hi('Exception',                  l:base8, '',      '')
    call s:hi('FoldColumn',                 l:baseC, l:base1, '')
    call s:hi('Folded',                     l:base3, l:base1, '')
    call s:hi('IncSearch',                  l:base1, l:base9, 'none')
    call s:hi('Italic',                     '',      '',      'none')
    call s:hi('Macro',                      l:base8, '',      '')
    call s:hi('MatchParen',                 l:base0, l:baseC, '')
    call s:hi('ModeMsg',                    l:baseB, '',      '')
    call s:hi('MoreMsg',                    l:baseB, '',      '')
    call s:hi('Question',                   l:baseD, '',      '')
    call s:hi('Search',                     l:base1, l:baseA, '')
    call s:hi('Substitute',                 l:base1, l:baseA, 'none')
    call s:hi('SpecialKey',                 l:base3, '',      '')
    call s:hi('TooLong',                    l:base8, '',      '')
    call s:hi('Underlined',                 l:baseD, '',      '')
    call s:hi('Visual',                     '',      l:base2, '')
    call s:hi('VisualNOS',                  l:base8, '',      '')
    call s:hi('WarningMsg',                 l:base8, '',      '')
    call s:hi('WildMenu',                   l:base8, '',      '')
    call s:hi('Title',                      l:baseD, '',      'none')
    call s:hi('Conceal',                    l:baseD, l:base0, '')
    call s:hi('Cursor',                     l:base0, l:base5, '')
    call s:hi('NonText',                    l:base3, '',      '')
    call s:hi('LineNr',                     l:base3, l:base1, '')
    call s:hi('SignColumn',                 l:base3, l:base1, '')
    call s:hi('StatusLine',                 l:base4, l:base1, 'none')
    call s:hi('StatusLineNC',               l:base3, l:base1, 'none')
    call s:hi('VertSplit',                  l:base2, l:base2, 'none')
    call s:hi('ColorColumn',                '',      l:base1, 'none')
    call s:hi('CursorColumn',               '',      l:base1, 'none')
    call s:hi('CursorLine',                 '',      l:base1, 'none')
    call s:hi('CursorLineNr',               l:base4, l:base1, '')
    call s:hi('QuickFixLine',               '',      l:base1, 'none')
    call s:hi('PMenu',                      l:base5, l:base1, 'none')
    call s:hi('PMenuSel',                   l:base1, l:base5, '')
    call s:hi('TabLine',                    l:base3, l:base1, 'none')
    call s:hi('TabLineFill',                l:base3, l:base1, 'none')
    call s:hi('TabLineSel',                 l:baseB, l:base1, 'none')

    " Standard syntax highlighting
    call s:hi('Boolean',                    l:base9, '',      '')
    call s:hi('Character',                  l:base8, '',      '')
    call s:hi('Comment',                    l:base3, '',      'italic')
    call s:hi('Conditional',                l:baseE, '',      '')
    call s:hi('Constant',                   l:base9, '',      '')
    call s:hi('Define',                     l:baseE, '',      'none')
    call s:hi('Delimiter',                  l:baseF, '',      '')
    call s:hi('Float',                      l:base9, '',      '')
    call s:hi('Function',                   l:baseD, '',      '')
    call s:hi('Identifier',                 l:base8, '',      'none')
    call s:hi('Include',                    l:baseD, '',      '')
    call s:hi('Keyword',                    l:baseE, '',      '')
    call s:hi('Label',                      l:baseA, '',      '')
    call s:hi('Number',                     l:base9, '',      '')
    call s:hi('Operator',                   l:base5, '',      'none')
    call s:hi('PreProc',                    l:baseA, '',      '')
    call s:hi('Repeat',                     l:baseA, '',      '')
    call s:hi('Special',                    l:baseC, '',      '')
    call s:hi('SpecialChar',                l:baseF, '',      '')
    call s:hi('Statement',                  l:base8, '',      '')
    call s:hi('StorageClass',               l:baseA, '',      '')
    call s:hi('String',                     l:baseB, '',      '')
    call s:hi('Structure',                  l:baseE, '',      '')
    call s:hi('Tag',                        l:baseA, '',      '')
    call s:hi('Todo',                       l:baseA, l:base1, '')
    call s:hi('Type',                       l:baseA, '',      'none')
    call s:hi('Typedef',                    l:baseA, '',      '')

    " C highlighting
    call s:hi('cOperator',                  l:baseC, '',      '')
    call s:hi('cPreCondit',                 l:baseE, '',      '')

    " C# highlighting
    call s:hi('csClass',                    l:baseA, '',      '')
    call s:hi('csAttribute',                l:baseA, '',      '')
    call s:hi('csModifier',                 l:baseE, '',      '')
    call s:hi('csType',                     l:base8, '',      '')
    call s:hi('csUnspecifiedStatement',     l:baseD, '',      '')
    call s:hi('csContextualStatement',      l:baseE, '',      '')
    call s:hi('csNewDecleration',           l:base8, '',      '')

    " CSS highlighting
    call s:hi('cssBraces',                  l:base5, '',      '')
    call s:hi('cssClassName',               l:baseE, '',      '')
    call s:hi('cssColor',                   l:baseC, '',      '')

    " Diff highlighting
    call s:hi('DiffAdd',                    l:baseB, l:base1, '')
    call s:hi('DiffChange',                 l:base3, l:base1, '')
    call s:hi('DiffDelete',                 l:base8, l:base1, '')
    call s:hi('DiffText',                   l:baseD, l:base1, '')
    call s:hi('DiffAdded',                  l:baseB, l:base0, '')
    call s:hi('DiffFile',                   l:base8, l:base0, '')
    call s:hi('DiffNewFile',                l:baseB, l:base0, '')
    call s:hi('DiffLine',                   l:baseD, l:base0, '')
    call s:hi('DiffRemoved',                l:base8, l:base0, '')

    " Git highlighting
    call s:hi('gitcommitOverflow',          l:base8, '',      '')
    call s:hi('gitcommitSummary',           l:baseB, '',      '')
    call s:hi('gitcommitComment',           l:base3, '',      '')
    call s:hi('gitcommitUntracked',         l:base3, '',      '')
    call s:hi('gitcommitDiscarded',         l:base3, '',      '')
    call s:hi('gitcommitSelected',          l:base3, '',      '')
    call s:hi('gitcommitHeader',            l:baseE, '',      '')
    call s:hi('gitcommitSelectedType',      l:baseD, '',      '')
    call s:hi('gitcommitUnmergedType',      l:baseD, '',      '')
    call s:hi('gitcommitDiscardedType',     l:baseD, '',      '')
    call s:hi('gitcommitBranch',            l:base9, '',      'bold')
    call s:hi('gitcommitUntrackedFile',     l:baseA, '',      '')
    call s:hi('gitcommitUnmergedFile',      l:base8, '',      'bold')
    call s:hi('gitcommitDiscardedFile',     l:base8, '',      'bold')
    call s:hi('gitcommitSelectedFile',      l:baseB, '',      'bold')

    " GitGutter highlighting
    call s:hi('GitGutterAdd',               l:baseB, l:base1, '')
    call s:hi('GitGutterChange',            l:baseD, l:base1, '')
    call s:hi('GitGutterDelete',            l:base8, l:base1, '')
    call s:hi('GitGutterChangeDelete',      l:baseE, l:base1, '')

    " HTML highlighting
    call s:hi('htmlBold',                   l:baseA, '',      '')
    call s:hi('htmlItalic',                 l:baseE, '',      '')
    call s:hi('htmlEndTag',                 l:base5, '',      '')
    call s:hi('htmlTag',                    l:base5, '',      '')

    " JavaScript highlighting
    call s:hi('javaScript',                 l:base5, '',      '')
    call s:hi('javaScriptBraces',           l:base5, '',      '')
    call s:hi('javaScriptNumber',           l:base9, '',      '')
    " pangloss/vim-javascript highlighting
    call s:hi('jsOperator',                 l:baseD, '',      '')
    call s:hi('jsStatement',                l:baseE, '',      '')
    call s:hi('jsReturn',                   l:baseE, '',      '')
    call s:hi('jsThis',                     l:base8, '',      '')
    call s:hi('jsClassDefinition',          l:baseA, '',      '')
    call s:hi('jsFunction',                 l:baseE, '',      '')
    call s:hi('jsFuncName',                 l:baseD, '',      '')
    call s:hi('jsFuncCall',                 l:baseD, '',      '')
    call s:hi('jsClassFuncName',            l:baseD, '',      '')
    call s:hi('jsClassMethodType',          l:baseE, '',      '')
    call s:hi('jsRegexpString',             l:baseC, '',      '')
    call s:hi('jsGlobalObjects',            l:baseA, '',      '')
    call s:hi('jsGlobalNodeObjects',        l:baseA, '',      '')
    call s:hi('jsExceptions',               l:baseA, '',      '')
    call s:hi('jsBuiltins',                 l:baseA, '',      '')

    " Mail highlighting
    call s:hi('mailQuoted1',                l:baseA, '',      '')
    call s:hi('mailQuoted2',                l:baseB, '',      '')
    call s:hi('mailQuoted3',                l:baseE, '',      '')
    call s:hi('mailQuoted4',                l:baseC, '',      '')
    call s:hi('mailQuoted5',                l:baseD, '',      '')
    call s:hi('mailQuoted6',                l:baseA, '',      '')
    call s:hi('mailURL',                    l:baseD, '',      '')
    call s:hi('mailEmail',                  l:baseD, '',      '')

    " Markdown highlighting
    call s:hi('markdownCode',               l:baseB, '',      '')
    call s:hi('markdownError',              l:base5, l:base0, '')
    call s:hi('markdownCodeBlock',          l:baseB, '',      '')
    call s:hi('markdownHeadingDelimiter',   l:baseD, '',      '')

    " NERDTree highlighting
    call s:hi('NERDTreeDirSlash',           l:baseD, '',      '')
    call s:hi('NERDTreeExecFile',           l:base5, '',      '')

    " PHP highlighting
    call s:hi('phpMemberSelector',          l:base5, '',      '')
    call s:hi('phpComparison',              l:base5, '',      '')
    call s:hi('phpParent',                  l:base5, '',      '')

    " Python highlighting
    call s:hi('pythonOperator',             l:baseE, '',      '')
    call s:hi('pythonRepeat',               l:baseE, '',      '')
    call s:hi('pythonInclude',              l:baseE, '',      '')
    call s:hi('pythonStatement',            l:baseE, '',      '')

    " Ruby highlighting
    call s:hi('rubyAttribute',              l:baseD, '',      '')
    call s:hi('rubyConstant',               l:baseA, '',      '')
    call s:hi('rubyInterpolationDelimiter', l:baseF, '',      '')
    call s:hi('rubyRegexp',                 l:baseC, '',      '')
    call s:hi('rubySymbol',                 l:baseB, '',      '')
    call s:hi('rubyStringDelimiter',        l:baseB, '',      '')

    " SASS highlighting
    call s:hi('sassidChar',                 l:base8, '',      '')
    call s:hi('sassClassChar',              l:base9, '',      '')
    call s:hi('sassInclude',                l:baseE, '',      '')
    call s:hi('sassMixing',                 l:baseE, '',      '')
    call s:hi('sassMixinName',              l:baseD, '',      '')

    " Signify highlighting
    call s:hi('SignifySignAdd',             l:baseB, l:base1, '')
    call s:hi('SignifySignChange',          l:baseD, l:base1, '')
    call s:hi('SignifySignDelete',          l:base8, l:base1, '')

    " Spelling highlighting
    call s:hi('SpellBad',                   l:base8, 'none',  'undercurl')
    call s:hi('SpellLocal',                 '',      'none',  'undercurl')
    call s:hi('SpellCap',                   '',      'none',  'undercurl')
    call s:hi('SpellRare',                  '',      'none',  'undercurl')

    " Startify highlighting
    call s:hi('StartifyBracket',            l:base3, '',      '')
    call s:hi('StartifyFile',               l:base7, '',      '')
    call s:hi('StartifyFooter',             l:base3, '',      '')
    call s:hi('StartifyHeader',             l:baseB, '',      '')
    call s:hi('StartifyNumber',             l:base9, '',      '')
    call s:hi('StartifyPath',               l:base3, '',      '')
    call s:hi('StartifySection',            l:baseE, '',      '')
    call s:hi('StartifySelect',             l:baseC, '',      '')
    call s:hi('StartifySlash',              l:base3, '',      '')
    call s:hi('StartifySpecial',            l:base3, '',      '')

    " Java highlighting
    call s:hi('javaOperator',               l:baseD, '',      '')

    " ALE
    call s:hi('ALEErrorSign',               l:base8, l:base1, 'bold')

    " vim-lsp
    call s:hi('LspErrorSign',               l:base8, l:base1, 'bold')
    call s:hi('LspWarningSign',             l:baseA, l:base1, 'bold')
    call s:hi('LspInformationSign',         l:baseB, l:base1, 'bold')
    call s:hi('LspHintSign',                l:baseE, l:base1, 'bold')
    call s:hi('LspHintText',                l:base3, l:base1, '')

    " coc
    call s:hi('CocErrorHighlight',          l:base8, '',      'underline')
    call s:hi('CocErrorSign',               l:base8, l:base1, 'bold')
    call s:hi('CocWarningSign',             l:baseA, l:base1, 'bold')
    call s:hi('CocInfoSign',                l:base2, l:base1, 'bold')
    call s:hi('CocHighlightText',           '',      l:base1, '')
endfunction
