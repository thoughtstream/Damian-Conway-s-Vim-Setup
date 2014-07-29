" Vim global plugin for aligning assignments and other similar symbols
" Last change:  Sat Apr 19 21:55:26 EST 2008
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_eqalignsimple")
    finish
endif
let loaded_eqalignsimple = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Align lines with an = in them,
" such as:

"        $x = 1
"        $longer_var = 1
"        $longer_var  += 1
"        $longer_var      = 1
"        $mid_var //= 1
"        $var = 1

" Or:

"        cat => 'feline',
"        lion = leo => 'leonine',
"        cow => 'bovine',
"        elephant => 'elephantine',

let s:QUOTELIKE
\   = '''\%(\\.\|[^''\\]\)*''\|'
\   . '"\%(\\.\|[^"\\]\)*"'

let s:LINE_WITH_EQ
\    = '^\(\%('.s:QUOTELIKE.'\|[^''"]\)\{-}\)\s*'
\    . '\(\%([~.*/%+-]\|||\?\|&&\?\|//\?\)\?=\@<!=[=~]\@!\)'
\    . '\s*\(.*\)$'

let s:LINE_WITH_EQ_VIM
\    = '^\(\%(\s*"\)\?\%('.s:QUOTELIKE.'\|[^''"]\)\{-}\)\s*'
\    . '\(\%([~.*/%+-]\|||\?\|&&\?\|//\?\)\?=\@<!=[=~]\@!\)'
\    . '\s*\(.*\)$'

function EQAS_Align (mode, ...) range
    let option = a:0 ? a:1 : {}

    "What symbol to align (defaults to '=' variants)...
    let search_pat = expand('%') =~ '\.vim$' ? s:LINE_WITH_EQ_VIM : s:LINE_WITH_EQ
    if strlen(get(option,'pattern',""))
        let search_pat = '^\(.\{-}\)\s*\(' . get(option,'pattern') . '\)\s*\(.*\)$'

    elseif get(option,'cursor')
        " If requested, work out what symbol is under cursor and align to that...
        let [bufnum, line_num, start_pos, offset] = getpos('.')
        let start_pos -= 1
        let end_pos = start_pos
        let curr_line = getline(line_num)
        let curr_char = curr_line[start_pos]

        "Classify the char under the cursor as space or keyword or other
        let sym_type = curr_char =~ '\s' ? '\s'
        \            : curr_char =~ '\k' ? '\k'
        \            :                     '\k\@!\S'

        "Walk back and forth from under cursor as long as chars are of same type...
        while start_pos > 0 && curr_line[start_pos-1] =~ sym_type
            let start_pos -= 1
        endwhile
        while end_pos < strlen(curr_line)-1 && curr_line[end_pos+1] =~ sym_type
            let end_pos += 1
        endwhile

        "The resulting sequence becomes the alignment symbol...
        let search_pat = '^\(.\{-}\)\s*\(\V' . curr_line[start_pos : end_pos] . '\m\)\(.*\)$'
    endif

    "Locate block of code to be considered (same indentation, no blanks)
    if a:mode == 'vmap'
        let firstline = a:firstline
        let lastline  = a:lastline
    elseif get(option, 'paragraph')
        let firstline  = search('^\s*$','bnW') + 1
        let lastline   = search('^\s*$', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
    else
        let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline  = search('^\%('. indent_pat . '\)\@!\|^\s*$','bnW') + 1
        let lastline   = search('^\%('. indent_pat . '\)\@!\|^\s*$', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
    endif

    " Decompose lines at assignment operators...
    let lines = []
    for linetext in getline(firstline, lastline)
        let field = matchlist(linetext, search_pat)
        if len(field) 
            call add(lines, {'lval':field[1], 'op':field[2], 'rval':field[3]})
        else
            call add(lines, {'text':linetext, 'op':''})
        endif
    endfor

    " Determine maximal lengths of lvalue and operator...
    let op_lines = filter(copy(lines),'!empty(v:val.op)')
    let max_lval = max( map(copy(op_lines), 'strlen(v:val.lval)') ) + 1
    let max_op   = max( map(copy(op_lines), 'strlen(v:val.op)'  ) )

    " Recompose lines with operators at the maximum length...
    let linenum = firstline
    for line in lines
        let newline = empty(line.op)
        \ ? line.text
        \ : printf("%-*s%*s%s", max_lval, line.lval, max_op, line.op, line.rval)

        call setline(linenum, newline)
        let linenum += 1
    endfor
endfunction


nmap <silent> =     :call EQAS_Align('nmap')<CR>
nmap <silent> ==    :call EQAS_Align('nmap', {'paragraph':1} )<CR>
nmap <silent> +     :call EQAS_Align('nmap', {'cursor':1} )<CR>
nmap <silent> ++    :call EQAS_Align('nmap', {'cursor':1, 'paragraph':1} )<CR>
vmap <silent> =     :call EQAS_Align('vmap')<CR>
vmap <silent> +     :call EQAS_Align('vmap', {'cursor':1} )<CR>

" Restore previous external compatibility options
let &cpo = s:save_cpo
