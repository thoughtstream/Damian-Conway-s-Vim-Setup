" Vim global plugin for files that execute their Vimscript contents when loaded
"
" Last change:  2020-06-19T20:01:55+0000
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_vimaction")
    finish
endif
let loaded_vimaction = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

function! s:act () abort
    if argc() > 1
        let prev_file = expand('#')
        let arg_index = argidx()
        if arg_index > 0 && argv(arg_index-1) ==# prev_file
            source %
        elseif arg_index < argc() && argv(arg_index+1) ==# prev_file
            previous
        endif
    endif
endfunction

augroup VimAction
    autocmd!
    autocmd BufEnter *.vimaction  call s:act()
augroup END

" Restore previous external compatibility options
let &cpo = s:save_cpo

