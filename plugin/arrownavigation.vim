" Vim global plugin for using arrows to navigate file lists and tabs
" Last change:  Wed Dec 21 21:41:19 AEDT 2016
" Maintainer:   Damian Conway
" License:  This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_arrnav")
    finish
endif
let loaded_arrnav = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Make it easy to navigate arglists, quickfixes, vimgreps, and multiple tabs
"  using the arrow keys
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"======[ Interface ]======================================================

" <UP> and <DOWN> jump to next file in the argument list,
" or (if there is no next file) to the next buffer in the quickfix or location list...
"
nmap <silent>  <UP>            :call ArrNav_PREV_FILE()<CR>
nmap <silent>  <DOWN>          :call ArrNav_NEXT_FILE()<CR>

" <LEFT> and <RIGHT> jump to next item
" in the quickfix list or location list
" or if both lists are empty, to the next tab...
"
nmap <silent>  <LEFT>          :call ArrNav_PREV_ITEM()<CR>
nmap <silent>  <RIGHT>         :call ArrNav_NEXT_ITEM()<CR>

" Double <LEFT> and <RIGHT> jump to next buffer
" in the quickfix list or location list...
"
nmap <silent>   <LEFT><LEFT>   :call ArrNav_PREV_BUFFER()<CR>
nmap <silent>  <RIGHT><RIGHT>  :call ArrNav_NEXT_BUFFER()<CR>


" Unset this flag to prevent <UP> and <DOWN> from falling back
" on iterating the buffers of the quickfix and location lists

if !exists('g:ArrNav_arglist_fallback')
    let g:ArrNav_arglist_fallback = 0
endif

" Redefine this to change the colour of warnings when no jump occurs
" (208 is a warm orange-brown on an xterm-256)

highlight default ArrNav_Warning ctermfg=208


"=====[ Implementation ]==================================================

" Edit the next file (or buffer)...
"
function! ArrNav_NEXT_FILE ()

    " If not at the final file of the argument list, go the the next file...
    if argidx() < argc() - 1
        silent next
        redraw!
        echomsg '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
        return
    endif

    " Otherwise, try the next buffer in the quickfix list...
    if g:ArrNav_arglist_fallback && len(getqflist())
        call ArrNav_NEXT_BUFFER()

    " Otherwise, try the next buffer in the location list...
    elseif g:ArrNav_arglist_fallback && len(getloclist(0))
        call ArrNav_NEXT_BUFFER()

    " Otherwise report the failure to change buffer using a distinct highlight
    else
        echohl ArrNav_Warning
        echomsg '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
        echohl NONE
    endif

endfunction


" Edit the previous file (or buffer)
"
function! ArrNav_PREV_FILE ()

    " If not at the first file of the argument list, go to the previous file...
    if argidx() > 0
        silent prev
        redraw!
        echomsg '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
        return
    endif

    " Otherwise, try the previous buffer in the quickfix list...
    if g:ArrNav_arglist_fallback && len(getqflist())
        call ArrNav_PREV_BUFFER()
        return

    " Otherwise, try the previous buffer in the location list...
    elseif g:ArrNav_arglist_fallback && len(getloclist(0))
        call ArrNav_PREV_BUFFER()

    " Otherwise report the failure to change buffer using a distinct highlight
    else
        echohl ArrNav_Warning
        echomsg '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
        echohl NONE
    endif

endfunction


" Jump to the previous item in the quickfix or location list, or to previous tab...
"
function! ArrNav_PREV_ITEM ()

    " Work out whether to use the quickfix or location list or the current set of tabs...
    let errors  = 1
    let list    = getqflist()
    let curridx = getqflist({'idx':1}).idx
    if empty(list)
        let errors  = 0
        let list    = getloclist(0)
        let curridx = getloclist(0,{'idx':1}).idx
    endif

    " If neither list active, try changing tabs, otherwise print a warning and we're done...
    if empty(list)
        if len(gettabinfo()) > 1
            tabprev
        else
            echohl ArrNav_Warning
            echomsg 'Nothing to step through'
            echohl NONE
        endif
        return
    endif

    " Try to jump to the preceding list item...
    let previdx = s:prev_from_here(list, curridx)
    if previdx < 1
        silent exec (errors ? 'cfirst! ' : 'lfirst! ')
        let type = list[0].type == 'w' ? ' warning' : ''
        echohl ArrNav_Warning
        echomsg '(1 of ' . len(list) . ')' . type . ': ' . list[0].text
        echohl NONE
    else
        if &autowrite && &modified && list[previdx-1].bufnr != list[curridx-1].bufnr
            try | write | finally | endtry
        endif
        exec (errors ? 'cc! ' : 'll! ') . previdx
    endif
endfunction

" Jump to the next item in the quickfix or location list, or to next tab...
"
function! ArrNav_NEXT_ITEM ()
    "
    " Work out whether to use the quickfix or location list or current set of tabs...
    let errors  = 1
    let list    = getqflist()
    let curridx = getqflist({'idx':1}).idx
    if empty(list)
        let errors  = 0
        let list    = getloclist(0)
        let curridx = getloclist(0,{'idx':1}).idx
    endif

    " If neither list active, try changing tabs, otherwise print a warning and we're done...
    if empty(list)
        if len(gettabinfo()) > 1
            tabnext
        else
            echohl ArrNav_Warning
            echo 'Nothing to step through'
            echohl NONE
        endif
        return
    endif

    " Try to jump to the next list item...
    let nextidx = s:next_from_here(list, curridx)
    if nextidx > len(list)
        silent exec (errors ? 'clast! ' : 'llast! ')
        let type = list[-1].type == 'w' ? ' warning' : ''
        if nextidx > len(list)
            echohl ArrNav_Warning
        endif
        echomsg '(' . len(list) . ' of ' . len(list) . ')' . type . ': ' . list[-1].text
        echohl NONE
    else
        if &autowrite && &modified && list[nextidx-1].bufnr != list[curridx-1].bufnr
            try | write | finally | endtry
        endif
        exec (errors ? 'cc! ' : 'll! ') . nextidx
    endif
endfunction


" Edit the previous buffer in the quickfix or location list...
"
function! ArrNav_PREV_BUFFER ()

    " If the quickfix list is active...
    if len(getqflist())

        " Try to jump to the previous buffer, otherwise highlight the failure...
        try
            cpfile | catch | noautocmd cfirst | redraw! | call ArrNav_PREV_ITEM() | finally
        endtry

    " Otherwise, try the location list...
    elseif len(getloclist(0))

        " Try to jump to the previous buffer, otherwise highlight the failure...
        try
            lpfile | catch | noautocmd lfirst | redraw! | call ArrNav_PREV_ITEM() | finally
        endtry
    endif
endfunction


" Edit the next buffer in the quickfix or location list...
function! ArrNav_NEXT_BUFFER ()

    " If the quickfix list is active...
    if len(getqflist())

        " Try to jump to the next buffer, otherwise highlight the failure...
        try
            cnfile | catch | noautocmd clast | redraw! | call ArrNav_NEXT_ITEM() | finally
        endtry

    " Otherwise, try the location list...
    elseif len(getloclist(0))

        " Try to jump to the next buffer, otherwise highlight the failure...
        try
            lnfile | catch | noautocmd llast | redraw! | call ArrNav_NEXT_ITEM() | finally
        endtry
    endif
endfunction

function! s:next_from_here(list, curridx) abort
    let [buf, lnum, col, off] = getpos('.')
    let buf = bufnr('%')
    let list = copy(a:list)
    call map(list, { k,v -> v.bufnr==buf && (v.lnum==lnum && v.col>col || v.lnum>lnum) ? k+1 : 0 })
    call filter(list, { k,v -> v > 0 })
    return get(list, 0, a:curridx+1)
endfunction

function! s:prev_from_here(list, curridx) abort
    let [buf, lnum, col, off] = getpos('.')
    let buf = bufnr('%')
    let list = copy(a:list)
    call map(list, { k,v -> v.bufnr==buf && (v.lnum==lnum && v.col<col || v.lnum<lnum) ? k+1 : 0 })
    call filter(list, { k,v -> v > 0 })
    return get(list, -1, a:curridx-1)
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
