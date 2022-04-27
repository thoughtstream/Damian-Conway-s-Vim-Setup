" Vim global plugin for aligning columns
" Last change:  Sat Apr 19 21:55:26 EST 2008
" Maintainer:   Damian Conway
" License:  This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_colalignsimple")
    finish
endif
let loaded_colalignsimple = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Align lines with an column in them,
" such as:

 "   The Shoveller | Eddie Stevens     King Arthur's singing shovel | M
"    Blue Raja     | Geoffrey Smith   Master of cutlery | M
 "   Mr Furious  | Roy Orson    Ticking time bomb of fury | M
    "   The Bowler| Carol Pinnsler    Haunted bowling ball | F

function! s:AlignWhitespaceCols (first_line, last_line)
    let lines = getline(a:first_line, a:last_line)
    let lines = map(copy(lines), 'split(''  '' . v:val,''\ze|\|\s\{2,}\zs'')')

    let aligned_lines = repeat([""], len(lines))
    let aligned = 0
    let colnum = 0
    while 1
        " Get next column to be added, if any...
        let column = map(copy(lines), 'get(v:val,colnum,"")')
        if max(map(copy(column), 'strdisplaywidth(v:val)')) == 0
            break
        endif

        " Work out alignment...
        let colpos = map(copy(aligned_lines), 'strdisplaywidth(v:val)')
        let maxpos = max(colpos)
        let minpos = min(colpos)

        " Misaligned? Then align...
        if !aligned && minpos != maxpos
            for linenum in range(len(column))
                let aligned_lines[linenum]
                \   = printf("%-*S%S",
                 \           maxpos, aligned_lines[linenum], column[linenum])
            endfor
            let aligned = 1
        else
            for linenum in range(len(column))
                let aligned_lines[linenum] .= column[linenum]
            endfor
        endif
        let colnum += 1
    endwhile

    call setline(a:first_line, map(aligned_lines, 'strpart(v:val,2)'))
endfunction

function! s:AlignPatternCols (first_line, last_line, separator, pattern)
    let lines = getline(a:first_line, a:last_line)
    let lines = map(copy(lines), 'split('' '' . v:val,a:pattern)')

    let aligned_lines = repeat([""], len(lines))
    let aligned = 0
    let colnum = 0
    while 1
        " Get next column to be added, if any...
        let column = map(copy(lines), 'get(v:val,colnum,"")')
        if max(map(copy(column), 'strdisplaywidth(v:val)')) == 0
            break
        endif

        " Work out alignment...
        let colpos = map(copy(aligned_lines), 'strdisplaywidth(v:val)')
        let maxpos = max(colpos)
        let minpos = min(colpos)

        " Misaligned? Then align...
        if !aligned && minpos != maxpos
            for linenum in range(len(column))
                let aligned_lines[linenum]
                \   = printf("%-*S%S%S",
                 \           maxpos, aligned_lines[linenum],
                  \          a:separator, column[linenum])
            endfor
            let aligned = 1
        else
            for linenum in range(len(column))
                let aligned_lines[linenum] .= a:separator . column[linenum]
            endfor
        endif
        let colnum += 1
    endwhile

    call setline(a:first_line, map(aligned_lines, 'strpart(v:val,1)'))
endfunction

function! s:Align ()
    "Locate block of code to be considered (same indentation, no blanks)
    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
    let first_line  = search('^\%('. indent_pat . '\)\@!\|^\s*$','bnW') + 1
    let last_line   = search('^\%('. indent_pat . '\)\@!\|^\s*$', 'nW') - 1
    if last_line < 0
        let last_line = line('$')
    endif

    "If no consistent indent, use the current block
    if first_line == last_line
        let first_line  = search('^\s*$','bnW') + 1
        let last_line   = search('^\s*$', 'nW') - 1
        if last_line < 0
            let last_line = line('$')
        endif
    endif

    " Convert char under cursor to pattern
    let target_char = getline('.')[col('.') - 1]
    if target_char =~ '\s\|\k'
        call <SID>AlignWhitespaceCols(first_line, last_line)
        return
    elseif target_char =~ '\\'
        let target_pat = '\\\\'
        call <SID>AlignPatternCols(first_line, last_line, target_char, target_pat)
        return
    else 
        let target_pat = '\V' . target_char
        call <SID>AlignPatternCols(first_line, last_line, target_char, target_pat)
        return
    endif

endfunction

nmap <silent> ]     :call <SID>Align()<CR>

" Restore previous external compatibility options
let &cpo = s:save_cpo
