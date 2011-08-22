" Vim global plugin for fillable abbreviations
" Last change:  Sat Aug 20 15:41:43 EEST 2011
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_fillabbr")
    finish
endif
let loaded_fillabbr = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Interface ]=====================================================

" Specify a fill abbreviation: Fillab <text> <margin_marker><replacement_with_placeholders>
command! -nargs=+  Fillab              call Fillab_Define(<q-args>)

" Specify the pattern that describes a placeholder (defaults to " underscores)...
command! -nargs=1  FillabPlaceholder   call Fillab_SetPlaceholder(<q-args>)

" Specify the Insert-mode key that jumps to the next placeholder...
command! -nargs=1  FillabEOFill        call Fillab_SetEOFill(<q-args>)


"=====[ Implementation ]================================================

" Standard placeholder is 3+ underscores, but can be changed...
let s:placeholder = '____*'

function! Fillab_SetPlaceholder (placeholder)
    let s:placeholder = a:placeholder
endfunction


" Standard end-of-fill character is <CR>, but can be changed...
let s:next_fill_char = '<CR>'

function! Fillab_SetEOFill (next_fill_char)
    let s:next_fill_char = a:next_fill_char
endfunction

augroup Fillab
    au!
augroup END

" This decodes the template and builds the appropriate insert-mode abbreviation...
function! Fillab_Define (text)
    " Separate arguments...
    let [match, filetype, keyword, margin, template; whatever]
    \   = matchlist(a:text, '\(\S\+\)\s\+\(\S\+\)\s\+\(\S\)\(.*\)')

    " Replace margin markers on second and later lines with newlines...
    let template = substitute(template, '\s*\V'.margin, '<CR>', 'g')

    " Work out how many placeholders...
    let placeholder_count = len(split(template, '_\{3,}', 1)) - 1

    " Build the appropriate abbreviation...
    if placeholder_count == 0
        exec 'au Fillab BufNewFile,BufRead ' . filetype . ' iab ' . keyword . ' ' . template
    else 
        exec 'au Fillab BufNewFile,BufRead ' . filetype . ' iab ' . keyword . ' ' . template
        \. '<ESC>:call Fillab_GoBack(' . placeholder_count . ')<CR>cw<C-O>:call getchar()<CR>'
    endif

endfunction

" Jump back to the first placeholder and set up the EOFill character to jump forward...
function! Fillab_GoBack (placeholders_remaining)
    " Jump back as many placeholders are the template added...
    for i in range(a:placeholders_remaining)
        call search(s:placeholder, 'bW')
    endfor

    " Set up the "jump-forward" key...
    exec 'imap ' . s:next_fill_char . ' <ESC>:call Fillab_GoForward(' . (a:placeholders_remaining-1) . ')<CR>cw'
endfunction

" Jump to the next placeholder and set up the EOFill character to jump forward (if appropriate)...
function! Fillab_GoForward (placeholders_remaining)
    " Jump fowrard to the next placeholder...
    if a:placeholders_remaining
        call search(s:placeholder, 'W')
    endif

    " Set up the "jump-forward" key, if appropriate...
    if a:placeholders_remaining > 1
        exec 'imap ' . s:next_fill_char . ' <ESC>:call Fillab_GoForward(' . (a:placeholders_remaining-1) . ')<CR>cw'
    else
        iunmap <CR>
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
