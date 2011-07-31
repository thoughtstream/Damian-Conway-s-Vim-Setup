" Vim global plugin for smarter completion semantics
" Last change:  Sat Apr 19 21:55:26 EST 2008
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_smartcom")
  finish
endif
let loaded_smartcom = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Remap single <S-TAB> for smart completion on entire lines...
inoremap <silent> <S-TAB> <c-r>=<SID>CompleteLine()<CR>

" Remap double <S-TAB> for smart completion on filenames...
inoremap <silent> <S-TAB><S-TAB> <c-r>=<SID>CompleteFile()<CR>

function! <SID>CompleteLine ()
    " If already completing, keep completing; otherwise, start completing...
    if pumvisible()
        return "\<C-P>"
    else
        return "\<C-X>\<C-L>"
    endif
endfunction

function! <SID>CompleteFile ()
    " If already completing, keep completing; otherwise, start completing...
    if pumvisible()
      return "\<C-P>"
    else
      return "\<C-X>\<C-F>"
    endif

endfunction

" Remap <TAB> for smart completion on various characters...
inoremap <silent> <TAB>   <c-r>=<SID>Complete()<CR>


" Completions table:
"   col 1 is left context,
"   col 2 is right context,
"   col 3 is what to insert
"   col 4 is whether to revert the cursor position
"   col 5 is an optional "filename pattern" to constrain where completion valid
let s:completions = []

" Public function to add other completions (which are tried first)
function! SmartcomAdd (left, right, completion, ...)
    let revert  = len(a:000) > 0 ? a:000[0] : 0
    let filepat = len(a:000) > 1 ? a:000[1] : 0
    call insert(s:completions, [a:left, a:right, a:completion, revert, filepat])
endfunction

" Completion action table:
"   col 1 is left context,
"   col 2 is right context,
"   col 3 is what to do
let s:completion_actions = []

" Public function to add completion actions (which are executed first)
function! SmartcomAddAction (left, right, action)
    call insert(s:completion_actions, [a:left, a:right, a:action])
endfunction


let s:NIL = ""

"                  Left   Right   Complete with...         Autorevert
"                  ====   =====   ====================     ==========
call SmartcomAdd(  '{',   s:NIL,  "}"                    , 1           )
call SmartcomAdd(  '{',   '}',    "\<CR>\<C-D>\<ESC>O"                 )
call SmartcomAdd(  '\[',  s:NIL,  "]"                    , 1           )
call SmartcomAdd(  '\[',  '\]',    "\<CR>\<ESC>O\<TAB>"                )
call SmartcomAdd(  '(',   s:NIL,  ")"                    , 1           )
call SmartcomAdd(  '(',   ')',    "\<CR>\<ESC>O\<TAB>"                 )
call SmartcomAdd(  '<',   s:NIL,   ">"                   , 1           )
call SmartcomAdd(  '<',   '>',    "\<CR>\<ESC>O\<TAB>"                 )
call SmartcomAdd(  '"',   s:NIL,  '"'                    , 1           )
call SmartcomAdd(  '"',   '"',    "\\n"                  , 1           )
call SmartcomAdd(  "'",   s:NIL,  "'"                    , 1           )
call SmartcomAdd(  "'",   "'",    s:NIL,                               )


let s:reset_complete_opt = {}

" Implement completion magic...
let s:tab = "\<TAB>"
function! <SID>Complete ()

    " Restore standard 'complete' option if necessary...
    let bufnum = bufnr('%')
    if has_key(s:reset_complete_opt, bufnum)
        let &l:complete = s:reset_complete_opt[bufnum]
        unlet s:reset_complete_opt[bufnum]
    endif

    " Tab as usual at the left margin...
    let cursorpos = getpos('.')
    let col = cursorpos[2]
    if col == 1
        return s:tab
    endif

    " How to revert the cursor position...
    let reversion = "\<C-O>:call setpos('.'," . string(cursorpos) . ")\<CR>"

    " Determine context of completion...
    let curr_line = getline('.')
    let curr_pos  = '\%' . col . 'c'

    " If a matching smart completion action has been specified, do it first...
    let old_complete_opt = &complete
    for [left, right, action] in s:completion_actions
        let pattern = left . curr_pos . right
        if curr_line =~ pattern
            execute action
        endif
    endfor
    if old_complete_opt != &complete
        let s:reset_complete_opt[bufnum] = old_complete_opt
    endif

    " If already in a completion pop-up selector, select the next alternative...
    if pumvisible()
        return "\<C-N>"
    endif

    " If a matching smart completion has been specified, use that...
    let filename = expand('%')
    for [left, right, completion, revert, filepat] in s:completions
        if filepat && filename !~ filepat
            continue
        endif
        let pattern = left . curr_pos . right
        if curr_line =~ pattern
            " Code around bug in setpos() when used at EOL...
            if col == strlen(curr_line)+1 && strlen(completion)==1 
                let reversion = "\<LEFT>"
            endif

            " Return the completion...
            return completion . (revert ? reversion : "")
        endif
    endfor

    " Otherwise, if not after an identifier, no completion; just a tab...
    if curr_line !~ '\k' . curr_pos
        return s:tab

    " Otherwise, autocomplete with next alternative
    else
        return "\<C-N>"

    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
