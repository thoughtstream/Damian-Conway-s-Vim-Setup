" Vim global plugin for selecting cells in a table in Visual mode
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_tablecellselect")
    finish
endif
let loaded_tablecellselect = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"######################################################
"##                                                  ##
"##  Usage:                                          ##
"##                                                  ##
"##      xnoremap <silent><expr>  c  VTC_select()    ##
"##                                                  ##
"##  (or whatever trigger character you prefer)      ##
"##                                                  ##
"##  Thereafter, typing 'c' in Visual mode selects   ##
"##  the current table cell (i.e. a block bounded    ##
"##  by blanks or boundary characters above and      ##
"##  below, and by two or more blanks or boundary    ##
"##  characters to the left and right).              ##
"##                                                  ##
"##  Typing a second 'c' once that cell is selected  ##
"##  extends the block to the entire table column.   ##
"##                                                  ##
"######################################################

let s:BLANK_LINE = '\_^[[:space:]|=_+-]*\_$'

function! VTC_select ()
    " Where is the cursor and the visual selection???
    let [ buffer,  line,  col,  offset] = getpos('.')
    let [vbuffer, vline, vcol, voffset] = getpos('v')
    let col += offset
    let vcol += voffset

    " Can't select if on a blank line...
    let cursor_line = getline(line)
    if cursor_line =~ s:BLANK_LINE
        return ""
    endif

    " Make the selection process look prettier...
    let resetlazyredraw = &lazyredraw ? ":\<C-U>set nolazyredraw\<CR>gv" : ""
    set lazyredraw

    " Find the vertical boundaries...
    let top_line = search(s:BLANK_LINE,'bn',1)
    let top_line = !top_line ? 1 : top_line+1

    let bot_line = search(s:BLANK_LINE,'ncW')
    let bot_line = !bot_line ? line('$') : bot_line-1

    " Grab those lines and pad them...
    let lines = getline(top_line, bot_line)
    let max_width = max(map(copy(lines), 'strlen(v:val)'))
    call map(lines, 'printf("%-'.(max_width+2).'s", v:val)')

    " Do we have visible margins (i.e. | something | )???
    let border = '\\\@![+|]'
    let content = '\(.\)'
    let visible_margins = border.'\%<'.(col+1).'v[- \t=]\(\\[+|]\|[^+|]\)\{-}[- \t=]'.border.'\%>'.col.'v'
    let cell_match = matchstrpos(cursor_line, visible_margins)
    if !empty(cell_match[0])
        let left_col  = cell_match[1]+2
        let right_col = cell_match[2]
    else
        let visible_margins = ""

        " Locate left margin...
        let left_col = col
        " If starting in a gap, move back to first non-gap...
        if s:vertical_gap_at(left_col-1, lines)
            while left_col > 1 && s:vertical_gap_at(left_col-2, lines)
                let left_col -= 1
            endwhile
        endif
        " Then move back to first gap...
        while left_col > 1 && !s:vertical_gap_at(left_col-2, lines)
            let left_col -= 1
        endwhile

        " Locate right margin...
        let right_col = left_col
        " Move to start of next gap...
        while col <= max_width && !s:vertical_gap_at(right_col, lines)
            let right_col += 1
        endwhile
        " Move to end of next gap...
        while col <= max_width && s:vertical_gap_at(right_col+1, lines)
            let right_col += 1
        endwhile
        let right_col = min([right_col+1, max_width])
    endif

    " Is it a re-match of the same cell???
    if  min([col,vcol])   == left_col && max([col,vcol])   == right_col
    \&& min([line,vline]) <= top_line && max([line,vline]) >= bot_line
        return VTC_extend(visible_margins) . resetlazyredraw
    endif

    " Return key sequence to select block...
    return (mode() != "\<C-V>" ? "\<C-V>" : "")
    \    . top_line . 'G'
    \    . left_col . '|'
    \    . 'o'
    \    . bot_line . 'G'
    \    . right_col . '|'
    \    . resetlazyredraw

endfunction

function! VTC_extend (visible_margins)
    " What have we selected already???
    let [cbuf, cline, ccol, coffset] = getpos('.')
    let [vbuf, vline, vcol, voffset] = getpos('v')
    let old_top_line = min([cline, vline])
    let old_bot_line = max([cline, vline])
    let left_col = min([ccol+coffset, vcol+voffset])
    let right_col = max([ccol+coffset, vcol+voffset])

    " Start at the current boundaries...
    let new_top_line = old_top_line
    let new_bot_line = old_bot_line

    " Generate pattern to match extra lines...
    if empty(a:visible_margins)
        let extend_pat = '\([[:space:]|=_+-]\{2}\|\_^[[:space:]|=_+-]\?\)\%'.left_col.'v\(.*\ze[[:space:]|=_+-]\{2}\%<'.(right_col+2).'v\|\(\([[:space:]|=_+-]\{2}\)\@!.\)*\_$\)'
    else
        let extend_pat = a:visible_margins
    endif

    " Walk upwards, checking for valid extra lines...
    for lnum in range(old_top_line-1,1,-1)
        let next_line = getline(lnum)
        if next_line =~ extend_pat || next_line =~ s:BLANK_LINE
            let new_top_line = lnum
            let line_width = strlen(substitute(matchstr(next_line,extend_pat),'^[[:space:]|=_+-]\+','',''))
            let right_col = max([right_col, left_col + line_width])
        else
            break
        endif
    endfor

    " Walk back down, excluding leading blank lines
    for lnum in range(new_top_line,old_top_line)
        let next_line = getline(lnum)
        if empty(a:visible_margins) && next_line =~ s:BLANK_LINE || strlen(next_line) < left_col
            let new_top_line = lnum+1
        else
            break
        endif
    endfor

    " Walk downwards, checking for valid extra lines...
    for lnum in range(old_bot_line+1,line('$'))
        let next_line = getline(lnum)
        if next_line =~ extend_pat || next_line =~ s:BLANK_LINE
            let new_bot_line = lnum
            let line_width = strlen(substitute(matchstr(next_line,extend_pat),'^[[:space:]|=_+-]\+','',''))
            let right_col = max([right_col, left_col + line_width])
        else
            break
        endif
    endfor

    " Walk back up, excluding trailing blank lines
    for lnum in range(new_bot_line,old_bot_line,-1)
        let next_line = getline(lnum)
        if empty(a:visible_margins) && next_line =~ s:BLANK_LINE || strlen(next_line) < left_col
            let new_bot_line = lnum-1
        else
            break
        endif
    endfor

    " Return key sequence to select block...
    return (mode() != "\<C-V>" ? "\<C-V>" : "")
    \    . new_top_line . 'G'
    \    . left_col     . '|'
    \    . 'o'
    \    . new_bot_line . 'G'
    \    . right_col    . '|'

endfunction


function! s:vertical_gap_at (col, lines)
    " Have we run out of range???
    if a:col < 1
        return 0
    endif

    " Look for any line without a gap at that column...
    for line in a:lines
        if line !~ '\%'.a:col.'v[[:space:]|=_+-]\{2}'
            return 0
        endif
    endfor

    " Otherwise, there's a gap...
    return 1
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
