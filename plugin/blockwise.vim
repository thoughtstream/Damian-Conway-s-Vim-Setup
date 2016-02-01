" Vim global plugin for restricting colon commands to visual blocks
" Last change:  blockwise
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_blockwise")
    finish
endif
let loaded_blockwise = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Interface ]===================

vmap  B  :Blockwise<SPACE>

command! -range -nargs=+ -com=command   Blockwise    silent call VBCexec(<q-args>)
command! -range -nargs=* -bang          SortByBlock  silent call VBCsort('<bang>', <q-args>)


"=====[ Implementation ]===================

function! VBCexec(cmd) range
    " Remember the length of the buffer...
    let orig_buflen = line('$')

    " Locate and record block being shifted...
    let [buf_left,  line_left,  col_left,  offset_left ] = getpos("'<")
    let [buf_right, line_right, col_right, offset_right] = getpos("'>")

    let lines_left  = getline(line_left, line_right)
    let lines_right = copy(lines_left)

    " Keep the before and aft...
    for n in range(len(lines_left))
        let lines_left[n]  = col_left > 1 ? lines_left[n][0 : col_left-2] : ""
        let lines_right[n] = lines_right[n][col_right : ]
    endfor

    " Work around a mysterious bug!
    let tmp = string(lines_left).string(lines_right) 

    " Remove the before and aft...
    if visualmode() ==# 'v'
        exec '''<,''>s/\%<'. col_left .'v.\|\%>'. col_right .'v.//g'
    endif

    " Execute the commands...
    exec '''<,''>' . a:cmd

    " Adjust the line count...
    let bufdiff = orig_buflen - line('$')
    if bufdiff > 0
        " Fewer lines left, so insert sufficient empty lines...
        call append(line_right - bufdiff, repeat([repeat(' ', col_right-col_left+1)], bufdiff))

    elseif bufdiff < 0
        " More lines left, so add extras...
        let lines_left  += repeat([repeat(' ', col_left-1)], -bufdiff)
        let lines_right += repeat([''], -bufdiff)
    endif

    " Reconstruct the lines...
    for n in range(len(lines_left))
        call setline(line_left + n, lines_left[n] . getline(line_left + n) . lines_right[n])
    endfor

    " Restore the selection...
    normal gv

endfunction


function! VBCsort(bang, options) range
    " Locate and record block being shifted...
    let [buf_left,  line_left,  col_left,  offset_left ] = getpos("'<")
    let [buf_right, line_right, col_right, offset_right] = getpos("'>")

    " If no options given, detect the type of sort required...
    if !len(a:options)
        let lines   = getline(line_left, line_right)
        let matches = filter(copy(lines), 'match(v:val['.(col_left-1).':'.(col_right-1).'], "^\\s*\\d") >= 0')
        let numeric = (len(lines) == len(matches)) ? 'n' : ''
        let options = ' '. numeric .' /.*\%' . col_left . 'v/'
    else
        let options = ' '. a:options .' /\%>'. (col_left-1) .'v.\{-}\%<'. (col_right+1) .'v./ r'
    endif

    " Remove the before and aft...
    exec line_left .','. line_right .' sort' . a:bang . ' ' . options

    " Restore the selection...
    normal gv

endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
