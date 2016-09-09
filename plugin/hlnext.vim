" Vim global plugin for highlighting matches
" Last change:  Thu Dec 19 16:08:21 EST 2013
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.
"
" After highlighting search results, shows the search result 
" that is found at the cursor in a different color.  Using N or n
" to jump forward or backward will update the result at the 
" cursor to be newly highlighted.
"
" Highlighting the next search result is done via the HLNext()
" function.  In order to remove search highlighting it is
" recommended to use a mapping similar to the following:
"
" nmap <silent> <BS> :call HLNextOff() <BAR> :nohlsearch<CR>
"
" If using documap.vim:
"
" Nmap <silent> <BS> [Cancel highlighting] :call HLNextOff() <BAR> :nohlsearch<CR> 
"
" If using documap.vim and either visualguide.vim or visualsmartia.vim
"
" Nmap <silent> <BS> [Cancel highlighting] :call HLNextOff() <BAR> :nohlsearch <BAR> :call VG_Show_CursorColumn('off')<CR> 

" If already loaded, we're done...
if exists("loaded_HLNext")
    finish
endif
let loaded_HLNext = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"====[ INTERFACE ]=============================================

if maparg('/','n') == ""
    nnoremap  <unique>         /   :call HLNextSetTrigger()<CR>/
endif
if maparg('?','n') == ""
    nnoremap  <unique>         ?   :call HLNextSetTrigger()<CR>?
endif
if maparg('n','n') == ""
    nnoremap  <unique><silent> n  n:call HLNext()<CR>
endif
if maparg('N','n') == ""
    nnoremap  <unique><silent> N  N:call HLNext()<CR>
endif

" Default highlighting for next match...
highlight default HLNext ctermfg=white ctermbg=red


"====[ IMPLEMENTATION ]=======================================

" Clear previous highlighting and set up new highlighting...
function! HLNext ()
    " Remove the previous highlighting, if any...
    call HLNextOff()

    " Add the new highlighting...
    let target_pat = '\c\%#\%('.@/.'\)'
    let w:HLNext_matchnum = matchadd('HLNext', target_pat)
endfunction

" Clear previous highlighting (if any)...
function! HLNextOff ()
    if (exists('w:HLNext_matchnum') && w:HLNext_matchnum > 0)
        call matchdelete(w:HLNext_matchnum)
        unlet! w:HLNext_matchnum
    endif
endfunction

" Prepare to active next-match highlighting after cursor moves...
function! HLNextSetTrigger ()
    augroup HLNext
        autocmd!
        autocmd  CursorMoved  *  :call HLNextMovedTrigger()
    augroup END
endfunction

" Highlight and then remove activation of next-match highlighting...
function! HLNextMovedTrigger ()
    augroup HLNext
        autocmd!
    augroup END
    call HLNext()
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
