" Vim global plugin for smarter CTRL-Y and CTRL-E
" Last change:  Thu Mar 12 22:16:49 EST 2009
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_smartvcopy")
  finish
endif
let loaded_smartvcopy = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

function! VCopy(dir)
    let column     = virtcol('.')
    let pattern    = '\%' . column . 'v.'
    let sourceline = search(pattern . '*\S', a:dir=='up' ? 'bnW' : 'nW')
    if !sourceline
        return ""
    else
        return matchstr(getline(sourceline), pattern)
    endif
endfunction

imap <silent>  <C-Y>  <C-R><C-R>=VCopy('up')<CR>
imap <silent>  <C-E>  <C-R><C-R>=VCopy('down')<CR>

" Restore previous external compatibility options
let &cpo = s:save_cpo
