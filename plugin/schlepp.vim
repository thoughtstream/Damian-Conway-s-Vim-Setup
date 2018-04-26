"Schlepp.vim - Easy movement of lines/blocks of text
"Maintainer:    Zachary Stigall <zirrostig <at> lanfort.org>
"Date:          9 March 2014
"License:       VIM
"
"Inspired by Damian Conway's DragVisuals
"  If you have not watched Damian Conway's More Instantly Better Vim, go do so.
"  http://programming.oreilly.com/2013/10/more-instantly-better-vim.html
"
"This differs in that it is an attempt to improve the code, make it faster and
"remove some of the small specific issuses that can seemingly randomly bite you
"when you least expect it. And add some new stuff :)
"IDEAS and TODO
"   Suppress Messages about 'x fewer lines'
"   Don't affect the users command and search history (Is this happening?)
"   UndoJoin needs to not join between Line and Block modes (may not already - untested)
"   Add padding function, that inserts a space or newline in the direction specified

if exists('g:Schlepp#Loaded')
    finish
endif
let g:Schlepp#Loaded = 1

"{{{ Schlepp Movement
"{{{ User Config
let g:Schlepp#allowSquishingLines = get(g:, 'Schlepp#allowSquishingLines', 0)
let g:Schlepp#allowSquishingBlock = get(g:, 'Schlepp#allowSquishingBlock', 0)
let g:Schlepp#trimWS = get(g:, 'Schlepp#trimWS', 1)
let g:Schlepp#reindent = get(g:, 'Schlepp#reindent', 0)
let g:Schlepp#useShiftWidthLines = get(g:, 'Schlepp#useShiftWidthLines', 0)
"}}}
"{{{  Mappings
noremap <unique> <script> <Plug>SchleppUp <SID>SchleppUp
noremap <unique> <script> <Plug>SchleppDown <SID>SchleppDown
noremap <unique> <script> <Plug>SchleppLeft <SID>SchleppLeft
noremap <unique> <script> <Plug>SchleppRight <SID>SchleppRight

noremap <SID>SchleppUp    :call <SID>Schlepp("Up")<CR>
noremap <SID>SchleppDown  :call <SID>Schlepp("Down")<CR>
noremap <SID>SchleppLeft  :call <SID>Schlepp("Left")<CR>
noremap <SID>SchleppRight :call <SID>Schlepp("Right")<CR>

"Reindent Mappings
"These are only done on VisualLine Mode
noremap <unique> <script> <Plug>SchleppIndentUp       <SID>SchleppIndentUp
noremap <unique> <script> <Plug>SchleppIndentDown     <SID>SchleppIndentDown
noremap <unique> <script> <Plug>SchleppToggleReindent <SID>SchleppToggleReindent

noremap <SID>SchleppIndentUp       :call <SID>Schlepp("Up", 1)<CR>
noremap <SID>SchleppIndentDown     :call <SID>Schlepp("Down", 1)<CR>
noremap <SID>SchleppToggleReindent :call <SID>SchleppToggleReindent()<CR>
"}}}
"{{{ s:Schlepp(dir, ...) range
function! s:Schlepp(dir, ...) range
"  The main function that acts as an entrant function to be called by the user
"  with a desired direction to move the seleceted text.
"  TODO:
"       Work with a count specifier eg. [count]<Up> moves lines count times
"       Maybe: Make word with a motion

    "Avoid errors in read-only buffers
    if ! &modifiable
        echo 'Read only buffer'
        call s:ResetSelection()
        return
    endif
    "Get what visual mode was being used
    normal! gv
    let l:md = mode()
    execute "normal! \<Esc>"

    "Safe return if unsupported
    "TODO: Make this work in visual mode
    if l:md ==# 'v'
        "Give them back their selection
        call s:ResetSelection()
    endif

    "Branch off into specilized functions for each mode, check for undojoin
    if l:md ==# 'V'
        "Reindent if necessary
        if a:0 >= 1
            let l:reindent = a:1
        else
            let l:reindent = g:Schlepp#reindent
        endif

        if s:CheckUndo(l:md)
            undojoin | call s:SchleppLines(a:dir, l:reindent)
        else
            call s:SchleppLines(a:dir, l:reindent)
        endif
    elseif l:md ==# ''
        if s:CheckUndo(l:md)
            undojoin | call s:SchleppBlock(a:dir)
        else
            call s:SchleppBlock(a:dir)
        endif
    endif
endfunction "}}}
"{{{ s:SchleppLines(dir, reindent)
function! s:SchleppLines(dir, reindent)
"  Logic for moving text selected with visual line mode

    "build normal command string to reselect the VisualLine area
    let l:fline = line("'<")
    let l:lline = line("'>")
    let l:reindent_cmd = (a:reindent ? 'gv=' : '')

    if a:dir ==? 'up' "{{{ Up
        if l:fline == 1 "First lines of file, move everything else down
            call append(l:lline, '')
            call s:ResetSelection()
        else
            execute "normal! :'<,'>m'<-2\<CR>" . l:reindent_cmd . 'gv'
        endif "}}}
    elseif a:dir ==? 'down' "{{{ Down
        if l:lline == line('$') "Moving down past EOF
            call append(l:fline - 1, '')
            call s:ResetSelection()
        else
            execute "normal! :'<,'>m'>+1\<CR>" . l:reindent_cmd . 'gv'
        endif "}}}
    elseif a:dir ==? 'right' "{{{ Right
        if g:Schlepp#useShiftWidthLines
            normal! gv>
        else
            for l:linenum in range(l:fline, l:lline)
                let l:line = getline(l:linenum)
                "Only insert space if the line is not empty
                if match(l:line, '^$') == -1
                    call setline(l:linenum, ' '.l:line)
                endif
            endfor
        endif
        call s:ResetSelection() "}}}
    elseif a:dir ==? 'left' "{{{ Left
        if g:Schlepp#useShiftWidthLines
            normal! gv<
        elseif g:Schlepp#allowSquishingLines || match(getline(l:fline, l:lline), '^[^ \t]') == -1
            for l:linenum in range(l:fline, l:lline)
                call setline(l:linenum, substitute(getline(l:linenum), "^\\s", '', ''))
            endfor
        endif
        call s:ResetSelection()
    endif "}}}
endfunction "}}}
"{{{ s:SchleppBlock(dir)
function! s:SchleppBlock(dir)
"  Logic for moving a visual block selection, this is much more complicated than
"  lines since I have to be able to part text in order to insert the incoming
"  line

    "Save virtualedit settings, and enable for the function
    let l:ve_save = &l:virtualedit
    "So that if something fails, we can set virtualedit back
    try
        setlocal virtualedit=all

        " While '< is always above or equal to '> in linenum, the column it
        " references could be the first or last col in the block selected
        let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
        let [l:lbuf, l:lline, l:lcol, l:loff] = getpos("'>")
        let [l:left_col, l:right_col]  = sort([l:fcol + l:foff, l:lcol + l:loff])
        if &selection ==# "exclusive" && l:fcol + l:foff < l:lcol + l:loff
            let l:right_col -= 1
        endif

        if a:dir ==? 'up' "{{{ Up
            if l:fline == 1 "First lines of file
                call append(0, '')
            endif
            normal! gvxkPgvkoko
            "}}}
        elseif a:dir ==? 'down' "{{{ Down
            if l:lline == line('$') "Moving down past EOF
                call append(line('$'), '')
            endif
            normal! gvxjPgvjojo
            "}}}
        elseif a:dir ==? 'right' "{{{ Right
            normal! gvxpgvlolo
            "}}}
        elseif a:dir ==? 'left' "{{{ Left
            if l:left_col == 1
                execute "normal! gvA \<esc>"
                if g:Schlepp#allowSquishingBlock || match(getline(l:fline, l:lline), '^[^ \t]') == -1
                    for l:linenum in range(l:fline, l:lline)
                        if match(getline(l:linenum), "^[ \t]") != -1
                            call setline(l:linenum, substitute(getline(l:linenum), "^\\s", '', ''))
                            execute 'normal! :' . l:linenum . "\<cr>" . l:right_col . "|a \<esc>"
                        endif
                    endfor
                endif
                call s:ResetSelection()
            else
                normal! gvxhPgvhoho
            endif
        endif "}}}

        "Strip Whitespace
        "Need new positions since the visual area has moved
        if g:Schlepp#trimWS
            let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
            let [l:lbuf, l:lline, l:lcol, l:loff] = getpos("'>")
            let [l:left_col, l:right_col]  = sort([l:fcol + l:foff, l:lcol + l:loff])
            if &selection ==# "exclusive" && l:fcol + l:foff < l:lcol + l:loff
                let l:right_col -= 1
            endif
            for l:linenum in range(l:fline, l:lline)
                call setline(l:linenum, substitute(getline(l:linenum), "\\s\\+$", '', ''))
            endfor
            "Take care of trailing space created on lines above or below while
            "moving past them
            if a:dir ==? 'up'
                call setline(l:lline + 1, substitute(getline(l:lline + 1), "\\s\\+$", '', ''))
            elseif a:dir ==? 'down'
                call setline(l:fline - 1, substitute(getline(l:fline - 1), "\\s\\+$", '', ''))
            endif
        endif

    endtry
    let &l:virtualedit = l:ve_save

endfunction "}}}
"{{{ s:SchleppToggleReindent()
function! s:SchleppToggleReindent()
    if g:Schlepp#reindent == 0
        let g:Schlepp#reindent = 1
    else
        let g:Schlepp#reindent = 0
    endif
    call s:ResetSelection()
endfunction "}}}
"}}}
"{{{ Schlepp Duplication
"{{{ User Config
let g:Schlepp#dupLinesDir = get(g:, 'Schlepp#dupLinesDir', 'down')
let g:Schlepp#dupBlockDir = get(g:, 'Schlepp#dupBlockDir', 'right')
let g:Schlepp#dupTrimWS = get(g:, 'Schlepp#dupTrimWS', 0)
""}}}
"{{{ Mappings
noremap <unique> <script> <Plug>SchleppDupUp <SID>SchleppDupUp
noremap <unique> <script> <Plug>SchleppDupDown <SID>SchleppDupDown
noremap <unique> <script> <Plug>SchleppDupLeft <SID>SchleppDupLeft
noremap <unique> <script> <Plug>SchleppDupRight <SID>SchleppDupRight
noremap <unique> <script> <Plug>SchleppDup <SID>SchleppDup

noremap <SID>SchleppDupUp    :call <SID>SchleppDup("Up")<CR>
noremap <SID>SchleppDupDown  :call <SID>SchleppDup("Down")<CR>
noremap <SID>SchleppDupLeft  :call <SID>SchleppDup("Left")<CR>
noremap <SID>SchleppDupRight :call <SID>SchleppDup("Right")<CR>
noremap <SID>SchleppDup      :call <SID>SchleppDup()<CR>
"}}}
"{{{ s:SchleppDup(...) range
function! s:SchleppDup(...) range
" Duplicates the selected lines/block of text

    "Avoid errors in read-only buffers
    if ! &modifiable
        echo 'Read only buffer'
        call s:ResetSelection()
        return
    endif

    "Get mode
    normal! gv
    let l:md = mode()
    execute "normal! \<Esc>"

    "Safe return if unsupported
    "TODO: Make this work in visual mode
    if l:md ==# 'v'
        "Give them back their selection
        call s:ResetSelection()
    endif

    "Branching to other functions for lines and blocks
    if l:md ==# 'V'
        "Get direction
        if a:0 >= 1
            let l:dir = a:1
        else
            let l:dir = g:Schlepp#dupLinesDir
        endif

        if l:dir ==? 'up' || l:dir ==? 'down'
            call s:SchleppDupLines(l:dir)
        else
            call s:ResetSelection()
            echom 'Left and Right duplication not supported for lines'
        endif
    elseif l:md ==# ''
        "Get direction
        if a:0 >= 1
            let l:dir = a:1
        else
            let l:dir = g:Schlepp#dupBlockDir
        endif

        call s:SchleppDupBlock(l:dir)
    endif
endfunction "}}}
"{{{ s:SchleppDupLines(dir)
function! s:SchleppDupLines(dir)
"  Logic for duplicating line selections
    if a:dir ==? 'up'
        let l:reselect = 'gv'
    elseif a:dir ==? 'down'
        let l:reselect = "'[V']"
    else
        call s:ResetSelection()
        return
    endif

    execute 'normal! gvyP' . l:reselect
endfunction "}}}
"{{{ s:SchleppDupBlock(dir)
function! s:SchleppDupBlock(dir)
"  Logic for duplicating block selections
    let l:ve_save = &l:virtualedit
    try
        setlocal virtualedit=all
        let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
        let [l:lbuf, l:lline, l:lcol, l:loff] = getpos("'>")
        let [l:left_col, l:right_col]  = sort([l:fcol + l:foff, l:lcol + l:loff], 's:NrCmp')
        if &selection ==# "exclusive" && l:fcol + l:foff < l:lcol + l:loff
            let l:right_col -= 1
        endif
        let l:numlines = (l:lline - l:fline) + 1
        let l:numcols = (l:right_col - l:left_col)

        if a:dir ==? 'up'
            if (l:fline - l:numlines) < 1
                "Insert enough lines to duplicate above
                for l:i in range((l:numlines - l:fline) + 1)
                    call append(0, '')
                endfor
                "Position of selection has changed
                let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
            endif

            let l:set_cursor = ":call cursor(getpos(\"'<\")[1:3])\<CR>" . l:numlines . 'k'
            execute 'normal! gvy' . l:set_cursor . 'Pgv'

        elseif a:dir ==? 'down'
            if l:lline + l:numlines >= line('$')
                for l:i in range((l:lline + l:numlines) - line('$'))
                    call append(line('$'), '')
                endfor
            endif
            execute "normal! gvy'>j" . l:left_col . '|Pgv'
        elseif a:dir ==? 'left'
            if l:numcols > 0
                execute 'normal! gvyP' . l:numcols . "l\<C-v>" . (l:numcols + (&selection ==# 'exclusive')) . 'l' . (l:numlines - 1) . 'jo'
            else
                execute "normal! gvyP\<C-v>"  . (l:numlines - 1) . 'jo'
            endif
        elseif a:dir ==? 'right'
            normal! gvyPgv
        else
            call s:ResetSelection()
        endif

        "Strip Whitespace
        "Need new positions since the visual area has moved
        if g:Schlepp#dupTrimWS != 0
            let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
            let [l:lbuf, l:lline, l:lcol, l:loff] = getpos("'>")
            let [l:left_col, l:right_col]  = sort([l:fcol + l:foff, l:lcol + l:loff])
            if &selection ==# "exclusive" && l:fcol + l:foff < l:lcol + l:loff
                let l:right_col -= 1
            endif
            for l:linenum in range(l:fline, l:lline)
                if l:right_col == len(getline(l:linenum))
                    call setline(l:linenum, substitute(getline(l:linenum), "\\s\\+$", '', ''))
                endif
            endfor
        endif
    endtry
    let &l:virtualedit = l:ve_save

endfunction "}}}
"}}}
"{{{ Utility Functions
"{{{ s:CheckUndo(md)
function! s:CheckUndo(md)
    if !exists('b:schleppState')
        let b:schleppState = {}
        let b:schleppState.lastNr = undotree().seq_last
        let b:schleppState.lastMd = a:md
        return 0
    endif

    if changenr() == undotree().seq_last && b:schleppState.lastNr == (changenr() - 1) &&  b:schleppState.lastMd == a:md
        return 1
    endif

    "else
    let b:schleppState.lastNr = undotree().seq_last
    let b:schleppState.lastMd = a:md
    return 0
endfunction
"}}}
"{{{ s:ResetSelection()
function! s:ResetSelection()
    execute "normal! \<Esc>gv"
endfunction
"}}}
"{{{ s:NrCmp(i1, i2)
function! s:NrCmp(i1, i2)
    return a:i1 - a:i2
endfunction
"}}}
"{{{ s:sw()
if exists('*shiftwidth')
    function! s:sw()
        return shiftwidth()
    endfunction
else
    function s:sw()
        return &shiftwidth
    endfunction
endif
"}}}

" vim: ts=4 sw=4 et fdm=marker
