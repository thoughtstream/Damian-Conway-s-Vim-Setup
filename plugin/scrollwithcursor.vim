" Vim global plugin for scrolling that preserves cursor location, wherever possible
" Last change:  Thu Aug 23 21:44:55 EST 2012
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_scrollwithcursor")
    finish
endif
let loaded_scrollwithcursor = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"====[ Scroll preserving cursor (as long as possible) ]======

nnoremap <silent><expr> <C-F>  <SID>JumpForwardWithCursor()
nnoremap <silent><expr> <C-B>  <SID>JumpBackwardWithCursor()
nnoremap <silent><expr> <C-D>  <SID>JumpDownWithCursor()
nnoremap <silent><expr> <C-U>  <SID>JumpUpWithCursor()

function! s:JumpForwardWithCursor ()
    let cursorpos = winline()

    " In the final windowful --> don't move...
    if line('.') + winheight(0) - &scrolloff >= line('$')
        return ""

    " At the top of a windowful --> scroll a full window...
    elseif cursorpos <= &scrolloff + 1
        return "\<C-F>"

    " In the middle of a windowful --> scroll to keep cursor on same line...
    else 
        let jumpdist = winheight(0) - 2 * &scrolloff - 1
        return repeat('j', jumpdist) . repeat('k', jumpdist)
    endif
endfunction

function! s:JumpBackwardWithCursor ()
    let cursorpos = winline()

    " In the first windowful --> don't move...
    if line('.') < winheight(0) - &scrolloff
        return ""

    " At the bottom of a windowful --> scroll a full window...
    elseif cursorpos >= winheight(0) - &scrolloff - 1
        return "\<C-B>"

    " In the middle of a windowful --> scroll to keep cursor on same line...
    else 
        let jumpdist = winheight(0) - 2 * &scrolloff - 1
        return repeat('k', jumpdist) . repeat('j', jumpdist)
    endif
endfunction

function! s:JumpDownWithCursor ()
    let cursorpos = winline()
    let halfheight = winheight(0)/2

    " In at top of window --> move cursor down a half window...
    if cursorpos <= &scrolloff + 1
        return "\<C-D>"

    " Otherwise --> move cursor line and cursor down half a window (max)...
    else
        let jumpdist = winheight(0) - 2 * &scrolloff - 1
        let offset = cursorpos <= halfheight ? 0 : cursorpos - halfheight
        return repeat('j', jumpdist-offset) . repeat('k', jumpdist-offset)
    endif
endfunction

function! s:JumpUpWithCursor ()
    let cursorpos = winline()
    let halfheight = winheight(0)/2

    " In at bottom of window --> move cursor up a half window...
    if cursorpos >= winheight(0) - &scrolloff - 1
        return "\<C-U>"

    " Otherwise --> move cursor line and cursor up half a window (max)...
    else
        let jumpdist = winheight(0) - 2 * &scrolloff - 1
        let offset = cursorpos >= halfheight ? 0 : cursorpos - halfheight
        return repeat('k', jumpdist+offset) . repeat('j', jumpdist+offset)
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
