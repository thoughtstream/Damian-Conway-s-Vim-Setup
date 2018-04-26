" Vim global plugin for autocreating missing directories
"
" Last change:  Sat May 20 10:21:31 BST 2017

" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_AutoMkdir")
    finish
endif
let loaded_AutoMkdir = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"======[ Magically build interim directories if necessary ]===================

function! AskQuit (msg, options, quit_option)
    if confirm(a:msg, a:options) == a:quit_option
        silent q!
    endif
endfunction

function! EnsureDirExists ()
    let required_dir = expand("%:h")
    if !isdirectory(required_dir)
        call AskQuit("Parent directory '" . required_dir . "' doesn't exist.",
             \       "&Create it\nor &Quit?", 2)

        try
            call mkdir( required_dir, 'p' )
        catch
            call AskQuit("Can't create '" . required_dir . "'",
            \            "&Quit\nor &Continue anyway?", 1)
        endtry
    endif
endfunction

augroup AutoMkdir
    autocmd!
    autocmd  BufNewFile  *  :call EnsureDirExists()
augroup END


" Restore previous external compatibility options
let &cpo = s:save_cpo

