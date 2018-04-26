" Vim global plugin for persistent Visual selections
" Last change:  Fri Jun 22 13:59:53 EST 2012
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_persistentvisuals")
    finish
endif
let loaded_persistentvisuals = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ Interface ]==========

let s:pv_active = 1

function! PV_On ()
    let s:pv_active = 1
endfunction

function! PV_Off ()
    let s:pv_active = 0
endfunction

function PV_Toggle ()
    let s:pv_active = !s:pv_active
endfunction

" When shifting, retain selection over multiple shifts...
silent! xmap     <unique><silent><expr>  >  <SID>ShiftKeepingSelection(">")
silent! xmap     <unique><silent><expr>  <  <SID>ShiftKeepingSelection("<")

" When case changing, retain selection...
silent! xnoremap <unique><silent><expr>  ~  <SID>OpKeepingSelection("~")
silent! xnoremap <unique><silent><expr>  L  <SID>OpKeepingSelection("u")
silent! xnoremap <unique><silent><expr>  U  <SID>OpKeepingSelection("U")
silent! xnoremap <unique><silent><expr>  J  <SID>OpKeepingSelection("J")

" When substituting, retain selection...
noautocmd silent! xnoremap <unique><silent><expr>  s  <SID>SubstKeepingSelection("s")
noautocmd silent! xnoremap <unique><silent><expr>  S  <SID>SubstKeepingSelection("S")
noautocmd silent! xnoremap <unique><silent><expr>  c  <SID>SubstKeepingSelection("c")
noautocmd silent! xnoremap <unique><silent><expr>  C  <SID>SubstKeepingSelection("C")

" When character changing, retain selection...
silent! xnoremap <unique><silent><expr>  r  <SID>ReplaceVisualSelection()

" Hit <RETURN> to escape visual mode...
silent! xnoremap <unique><silent>        <CR>   <ESC>

" Hit ZZ to quit from within visual mode...
silent! xnoremap <unique><silent>        ZZ     <ESC>ZZ

" Allow selection to persist through an undo...
silent! xnoremap <unique><silent>        u      <ESC>ugv
silent! xnoremap <unique><silent>        <C-R>  <ESC><C-R>gv


"=====[ Implementation ]===========

function! s:ShiftKeepingSelection(cmd)
    set nosmartindent

    " No-op if plugin not active, or tab expansions are off...
    if !s:pv_active || !&expandtab
        return a:cmd . ":set smartindent\<CR>"

    " Visual and Visual Line modes...
    elseif mode() =~ '[vV]'
        return a:cmd . ":set smartindent\<CR>gv"

    " Visual block mode...
    else
        " Set up a temporary convenience...
        nnoremap <silent><expr><buffer>  M  <SID>ResetBlockSelection()

        " Work out the adjustment for the way we're shifting...
        let b:_pv_shift_motion
        \   = &shiftwidth . (a:cmd == '>' ?  "\<RIGHT>" : "\<LEFT>")

        " Return instructions to implement the shift and reset selection...
        return a:cmd . ":set smartindent\<CR>uM"
    endif
endfunction

function! s:ResetBlockSelection ()
    let motion = b:_pv_shift_motion

    " Clean up the temporary convenience...
    nunmap <buffer>  M

    " Locate block being shifted...
    let [buf_left,  line_left,  col_left,  offset_left ] = getpos("'<")
    let [buf_right, line_right, col_right, offset_right] = getpos("'>")

    " Locate text being shifted...
    let lines = getline(line_left, line_right)
    let unshiftable = '\%' . (col_left+offset_left) . 'v\s*'

    let min_lead = min(map(lines, "strlen(matchstr(v:val, '" . unshiftable . "'))"))

    " Is the selected text going to shift???
    if motion =~ "\<LEFT>" && min_lead <= 0
        let motion = ''
    endif

    " Return instructions to reset visual selection...
    return "\<C-R>\<C-V>" . line_right . 'G' . (col_right+offset_right) . '|' . motion
endfunction

function! PV_Notify (event)
    if exists('#User#PV_' . a:event)
        exec 'doautocmd User PV_' . a:event
    endif
endfunction

function! s:SubstKeepingSelection (cmd)
    call PV_Notify('Start')
    if s:pv_active
        inoremap <ESC>  <ESC>:silent exec 'iunmap <'.'ESC>'<CR>:call PV_Notify('End')<CR><C-L><CR>gvoO`]<LEFT>
    endif

    return a:cmd
endfunction

function! s:OpKeepingSelection (cmd)
    if s:pv_active
        return a:cmd . "gv"
    else
        return a:cmd
    endif
endfunction

function! s:ReplaceVisualSelection ()
    let c = nr2char(getchar())
    return 'r' . c . (s:pv_active ? 'gv' : '')
endfunction

function! _capture (count)
    return '\(.\{' . a:count . '}\)'
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
