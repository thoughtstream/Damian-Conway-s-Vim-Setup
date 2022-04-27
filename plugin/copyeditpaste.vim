" Vim global plugin for editing selected text then pasting it back
"
" Last change:  2018-05-29T20:35:36+0200
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_copyeditpaste")
    finish
endif
let loaded_copyeditpaste = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

command -nargs=1 CopyEditPaste  call _CEP_setup(<q-args>)

function! _CEP_setup (proc)
    let tempfile = tempname()
    exec "edit " . tempfile
    normal "+p
    %s/ / /ge
    let procfront = 'tell application "System Events" to set frontmost of application process "'
                 \. a:proc . '" to true'
    exec 'nnoremap <buffer> ZZ :w! ~/tmp/last_copyeditpaste<CR>:%yank +<CR>:%yank c<CR>:!osascript -e ''' . procfront . "'<CR>ZZ"
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo

