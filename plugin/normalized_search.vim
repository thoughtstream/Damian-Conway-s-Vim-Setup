" Vim global plugin for Unicode Normalized search
" Last change:  Mon Jul  4 07:27:26 EST 2011
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_normalized_search")
    finish
endif
let loaded_normalized_search = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

let s:NL = "\n"
let s:NORMALIZER = 'cat'
let s:last_pattern = ''

function! NormalizedSearch (pattern)

    " If none provided, default to reusing previous pattern...
    let pattern = a:pattern != "" ? a:pattern : s:last_pattern
    if pattern == ""
        echohl ErrorMsg
        echomsg 'E35: No previous regular expression'
        echohl None
        return
    endif
    let s:last_pattern = pattern

    " Where are we???
    let curr_line = line('.')
    let curr_pos  = getpos('.')

    " Grab entire buffer text, select everything after cursor, and normalize it...
    let buffer_text    = getline(1,'$')
    let post_text      = buffer_text[curr_line-1 : ]
    let post_text[0]   = strpart(post_text[0],curr_pos[2])
    let normalized_post = split(system(s:NORMALIZER, join(post_text,s:NL) . s:NL), s:NL, 1)

    " Find the right line (looking forward)...
    let line_match = match(normalized_post, pattern)

    if line_match >= 0
        " Found a match, so make the line number absolute...
        let col_match = match(normalized_post[line_match], pattern)
        let line_match += curr_line-1

        " If found later on current line, make column number absolute too...
        if line_match == curr_line-1
            let col_match += curr_pos[2]
        endif
    else
        " Grab wrapped buffer text, normalize it, and search...
        let curr_line = 1
        let normalized_text = split(system(s:NORMALIZER, join(buffer_text,s:NL) . s:NL), s:NL, 1)
        let line_match = match(normalized_text, pattern)

        " Report the final outcome...
        if line_match == -1
            echohl ErrorMsg
            echomsg 'E486: Pattern not found: ' . pattern
            echohl None
            return
        else
            echohl WarningMsg
            echomsg 'search hit BOTTOM, continuing at TOP'
            echohl None
        endif

        let col_match = match(normalized_text[line_match], pattern)
    endif

    " Go to the location found...
    let curr_pos[1] = line_match + 1
    let curr_pos[2] = col_match + 1
    call setpos('.', curr_pos)

endfunction

" Change the normalizing program...
command -nargs=1 -complete=shellcmd NormalizedSearchUsing  :let s:NORMALIZER = <q-args>

" Search interface is either by colon command...
command -nargs=? NormalizedSearch :call NormalizedSearch(<q-args>)

" Or by double-/ Normal-mode command...
nmap <unique> // :call NormalizedSearch( input('//', "") )<CR>

" Restore previous external compatibility options
let &cpo = s:save_cpo
