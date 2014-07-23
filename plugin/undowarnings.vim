" Vim global plugin adding warnings to persistent undo
" Last change:  Tue Jun 19 17:25:10 EST 2012
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_undowarnings")
    finish
endif
let loaded_undowarnings = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ INTERFACE ]==================

" Remap the undo key to warn about stepping back into a buffer's pre-history...
nnoremap <expr> u  VerifyUndo()

"=====[ IMPLEMENTATION ]==================
"
" Track each buffer's starting position in the undo history...
augroup UndoWarnings
    autocmd!
    autocmd BufReadPost,BufNewFile  *   :call Rememberundo_start()
augroup END

function! Rememberundo_start ()
    let b:undo_start = exists('b:undo_start') ? b:undo_start : undotree().seq_cur
endfunction

function! VerifyUndo ()
    " Nothing to verify if can't undo into previous sesssion...
    if !exists('*undotree')
        return 'u'
    endif

    " Are we back at the start of this session (but still with undos possible)???
    let undo_now = undotree().seq_cur

    " If so, check whether to undo into pre-history...
    if undo_now > 0 && undo_now == b:undo_start
        return confirm('',"Undo into previous session? (&Yes\n&No)",1) == 1 ? "\<C-L>u" : "\<C-L>"

    " Otherwise, always undo...
    else
        return 'u'
    endif
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
