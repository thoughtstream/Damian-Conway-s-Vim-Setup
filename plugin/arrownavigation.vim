" Vim global plugin for using arrows to navigate file lists
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
"  Make it easy to navigate arglists, quickfixes, and vimgreps
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
" in the quickfix list or location list...
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
"
highlight default ArrNav_Warning ctermfg=208


"=====[ Implementation ]==================================================

" Edit the next file (or buffer)...
"
function! ArrNav_NEXT_FILE ()

    " If not at the final file of the argument list, go the the next file...
    if argidx() < argc() - 1
        silent next
        redraw!
        echo '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
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
        echo '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
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
        echo '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
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
        echo '(' . (argidx()+1) . ' of ' . argc() . '): ' . expand('%')
        echohl NONE
    endif

endfunction


" Jump to the previous item in the quickfix or location list...
"
function! ArrNav_PREV_ITEM ()

    " Work out whether to use the quickfix or location list...
    let errors = 1
    let list = getqflist()
    if empty(list)
        let list = getloclist(0)
        let errors = 0
    endif

    " If neither list active, print a warning and we're done...
    if empty(list)
        echohl ArrNav_Warning
        echo 'Nothing to step through'
        echohl NONE
        return
    endif

    " Try to jump to the preceding list item...
    try
        if errors | cprev | else | lprev | endif
        redraw

        " On failure, must be at the first element,
        " so jump to it and reproduce the report in the warning colour...
        catch
            try
                if errors | silent cfirst | else | silent lfirst | endif
                let first = get(list,0,{'text':'', 'type':''})
                let type = first.type == 'w' ? ' warning' : ''
                echohl ArrNav_Warning
                echo '(1 of ' . len(list) . ')' . type . ': ' . first.text
                echohl NONE
                redraw
            endtry
        finally
    endtry
endfunction

" Jump to the next item in the quickfix or location list...
"
function! ArrNav_NEXT_ITEM ()
    "
    " Work out whether to use the quickfix or location list...
    let errors = 1
    let list = getqflist()
    if empty(list)
        let list = getloclist(0)
        let errors = 0
    endif

    " If neither list active, print a warning and we're done...
    if empty(list)
        echohl ArrNav_Warning
        echo 'Nothing to step through'
        echohl NONE
        return
    endif

    " Try to jump to the next list item...
    try
        if errors | cnext | else | lnext | endif
        redraw

        " On failure, must be at the last element,
        " so jump to it and reproduce the report in the warning colour...
        catch
            try
                if errors | silent clast | else | silent llast | endif
                let listlen = len(list)
                let final = get(list,-1,{'text':'', 'type':''})
                let type = final.type == 'w' ? ' warning' : ''
                echohl ArrNav_Warning
                echo '(' . listlen . ' of ' . listlen . ')' . type . ': ' . final.text
                echohl NONE
                redraw
            endtry
        finally
    endtry
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


" Restore previous external compatibility options
let &cpo = s:save_cpo
