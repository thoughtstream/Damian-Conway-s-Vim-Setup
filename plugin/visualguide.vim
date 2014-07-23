" Vim global plugin for guide markers in visual mode
" Last change:  Tue Jun 19 17:39:12 EST 2012
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_visualguide")
    finish
endif
let loaded_visualguide = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ INTERFACE ]===============

vnoremap <silent>  I  I<C-R>=<SID>TemporaryColumnMarkerOn()<CR>
vnoremap <silent>  A  A<C-R>=<SID>TemporaryColumnMarkerOn()<CR>

" Turn Visual mode column autoguide on...
function! VG_On ()
    let b:visual_guide_active = 1
endfunction

" Turn Visual mode column autoguide off...
function! VG_Off ()
    let b:visual_guide_active = 0
endfunction

" Turn Visual mode column autoguide on/off...
function! VG_Toggle ()
    let b:visual_guide_active = !b:visual_guide_active
endfunction

" Manually turn column guide on or off...
function! VG_Show_CursorColumn (requested_state)
    set cursorcolumn
    if a:requested_state == 'off' || g:cursorcolumn_visible && a:requested_state == 'flip'
        let g:cursorcolumn_visible = 0
        highlight clear CursorColumn
        highlight CursorColumn term=none cterm=none
    else
        let g:cursorcolumn_visible = 1
        highlight CursorColumn term=bold ctermfg=black ctermbg=cyan cterm=bold
    endif
endfunction


"=====[ IMPLEMENTATION ]===============

" Implement cursor column toggle...
let g:cursorcolumn_visible = 0

" Turn on guide marker and prep <ESC> to turn it off...
function! s:TemporaryColumnMarkerOn ()
    " Play nice with other guide markers...
    let g:prev_cursorcolumn_state = g:cursorcolumn_visible ? 'on' : 'off'

    " Actually turn the column on...
    call VG_Show_CursorColumn('on')

    " Remember whether it should be turned off automatically...
    inoremap <silent>  <ESC>  <ESC>:call <SID>TemporaryColumnMarkerOff(g:prev_cursorcolumn_state)<CR>
    return ""
endfunction

" Turn off column guide *if requested to) and forget the automation...
function! s:TemporaryColumnMarkerOff (newstate)
    call VG_Show_CursorColumn(a:newstate)
    iunmap <ESC>
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
