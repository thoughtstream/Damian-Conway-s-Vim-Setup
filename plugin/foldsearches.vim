" Vim global plugin for folding text around search results
" Last change:  Wed Aug 10 10:06:31 BST 2011
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_foldsearch")
    finish
endif
let loaded_foldsearch = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Interface...
nmap <silent><expr>  zz  <SID>ToggleFoldSearch()

" Remember default behaviours...
let s:DEFFOLDMETHOD = &foldmethod
let s:DEFFOLDEXPR   = &foldexpr
let s:DEFFOLDTEXT   = &foldtext

" This is what the options are changed to...
let s:FOLDEXPR = 'FoldSearchLevel()'
let s:FOLDTEXT = "'___/ line ' . (v:foldend+1) . ' \\' . repeat('_',200) "

" Turn the mechanism on and off...
function! s:ToggleFoldSearch ()
    " Make sure we can remember the previous setup...
    if !exists('b:foldsearch')
        let b:foldsearch = { 'active' : 0 }
    endif

    " Encapsulate all autocommands...

    " Turn off, if it's on...
    if b:foldsearch.active
        let &foldmethod = get(b:foldsearch, 'prevfoldmethod', s:DEFFOLDMETHOD)
        let &foldexpr   = get(b:foldsearch, 'prevfoldexpr',   s:DEFFOLDEXPR)
        let &foldtext   = get(b:foldsearch, 'prevfoldtext',   s:DEFFOLDTEXT)
        let &foldlevel  = 1

        " Stop recalculating folding...
        augroup FoldSearch
            autocmd!
        augroup END

        " Remember that it's off...
        let b:foldsearch.active = 0

    " Turn on, if it's off...
    else

        " Save old settings...
        let b:foldsearch.prevfoldmethod = &foldmethod
        let b:foldsearch.prevfoldexpr   = &foldexpr
        let b:foldsearch.prevfoldtext   = &foldtext

        " Set up new behaviour...
        let &foldtext   = s:FOLDTEXT
        let &foldexpr   = s:FOLDEXPR
        let &foldmethod = 'expr'
        let &foldlevel  = 0

        " Recalculate folding for each new search...
        augroup FoldSearch
            autocmd!
            autocmd CursorMoved  *  let &foldexpr  = &foldexpr
            autocmd CursorMoved  *  let &foldlevel = 0
        augroup END

        " Remember that it's on...
        let b:foldsearch.active = 1

    endif
    augroup END
endfunction

function! FoldSearchLevel ()
    let startline = v:lnum > 1         ? v:lnum - 1 : v:lnum
    let endline   = v:lnum < line('$') ? v:lnum + 1 : v:lnum
    let context = getline(startline, endline)
    return match(context, @/) == -1
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
