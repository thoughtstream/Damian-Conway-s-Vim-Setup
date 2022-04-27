" Vim global plugin for highlighting hard-to-see errors in Perl regexes
"
" Last change:  2020-02-15T04:35:59+0000
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_perlregexwarnings")
    finish
endif
let loaded_perlregexwarnings = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

augroup PerlRegexWarnings
    autocmd!
    autocmd Filetype perl  highlight PerlRegexWarnings term=bold cterm=bold ctermfg=white ctermbg=red gui=bold guifg=white guibg=red
    autocmd Filetype perl  call matchadd( 'PerlRegexWarnings', '(?\h\w*[^:-]\|(&?\?\h\w*)\|(<?\?\h\w*>\(\_s*\(\S\&[^)]\)\)\@=' )
augroup END

" Restore previous external compatibility options
let &cpo = s:save_cpo

