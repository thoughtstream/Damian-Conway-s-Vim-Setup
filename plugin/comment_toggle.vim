" Vim global plugin for toggling comments with the # key
"
" Last change:  2017-08-04T13:23:45+0100
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_comment_toggle")
    finish
endif
let loaded_comment_toggle = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Interface ]===============================
"
" # in Normal mode toggles a comment at the start of the current line
" # in Visual mode comments the selection (with a delimited comment if possible)
" # in Visual Line mode comments out each line in the selection
" # in Visual Block mode comments out everything to the right of the block's left boundary
"
" To add comment markers for unsupported filetypes, set a buffer variable
" Set b:CT_EOL_COMMENT to a string representing the comment-to-end-of-line marker
" Set b:CT_DELIMITED_COMMENT to a dictionary containing the delimited-comment delimiters
" You can set both for any given filetype. For example:
"
"   autocmd FILETYPE C  let b:CT_EOL_COMMENT       = '//'
"   autocmd FILETYPE C  let b:CT_DELIMITED_COMMENT = { 'start': '/*', 'end': '*/' }
"

nmap     <silent> # :call ToggleComment()<CR><CR>0
xnoremap <silent> # :call ToggleCommentV()<CR>


"=====[ Implementation ]===============================

" Work out what the comment character is, by filetype...
augroup CommentSupport
    autocmd!
    autocmd FileType             *sh,awk,python,perl,perl6,ruby    let b:CT_EOL_COMMENT = get(b:, 'CT_EOL_COMMENT', '#')
    autocmd FileType             vim                               let b:CT_EOL_COMMENT = get(b:, 'CT_EOL_COMMENT', '"')
    autocmd BufNewFile,BufRead   *.vim,.vimrc                      let b:CT_EOL_COMMENT = get(b:, 'CT_EOL_COMMENT', '"')
    autocmd BufNewFile,BufRead   *                                 let b:CT_EOL_COMMENT = get(b:, 'CT_EOL_COMMENT', '#')
    autocmd BufNewFile,BufRead   *.p[lm],.t                        let b:CT_EOL_COMMENT = get(b:, 'CT_EOL_COMMENT', '#')

    autocmd FileType  perl6    let b:CT_DELIMITED_COMMENT = get(b:, 'CT_DELIMITED_COMMENT', {'start': '#`{{{', 'end': '}}}' })
augroup END

" Work out whether the line has a comment then reverse that condition...
function! ToggleComment ()
    call inputsave()
    " What's the comment character???
    let comment_char = exists('b:CT_EOL_COMMENT') ? b:CT_EOL_COMMENT : '#'

    " Grab the line and work out whether it's commented...
    let currline = getline(".")

    " If so, remove it and rewrite the line...
    if currline =~ '^' . comment_char
        let repline = substitute(currline, '^' . comment_char, "", "")
        call setline(".", repline)

    " Otherwise, insert it...
    else
        let repline = substitute(currline, '^', comment_char, "")
        call setline(".", repline)
    endif
    call inputrestore()
endfunction

" Toggle comments down an entire visual selection of lines...
function! ToggleCommentV () range
    " What's the comment character???
    let comm_char  = get(b:, 'CT_EOL_COMMENT', '#')
    let comm_delim = get(b:, 'CT_DELIMITED_COMMENT', 0 )

    " Select behaviour according to visual mode...
    let mode = visualmode()
    if mode ==# 'V'
        call ToggleCommentVisualLine(comm_char, a:firstline, a:lastline)
    else
        let [buf_left,  line_left,  col_left,  offset_left ] = getpos("'<")
        let [buf_right, line_right, col_right, offset_right] = getpos("'>")
        if mode ==# 'v'
            call ToggleCommentVisual(comm_char, comm_delim, a:firstline, a:lastline, col_left-1, col_right-1)
        else
            call ToggleCommentVisualBlock(comm_char, a:firstline, a:lastline, col_left-1, col_right-1)
        endif
    endif
endfunction

function! ToggleCommentVisualBlock (comm_char, startline, endline, firstcol, lastcol) abort
    " Start at the first line...
    let linenum = a:startline

    " Get all the lines
    let currline = getline(a:startline, a:endline)

    " Decide their comment state by examining the first line...
    if currline[0][a:firstcol : ] =~ '^' . a:comm_char
        " If the first line is commented, decomment all...
        for line in currline
            call setline(linenum,
                    \   ( a:firstcol>0 ? line[0 : a:firstcol-1] : '')
                    \ . substitute(line[a:firstcol:], '^' . a:comm_char, "", "") )
            let linenum += 1
        endfor

    else
        " Otherwise, encomment all...
        let opt_comm = '^\('. a:comm_char . '\)\?'
        for line in currline
            let line .= repeat(' ', a:firstcol - strchars(line))
            call setline(linenum,
                    \   ( a:firstcol > 0 ? line[0 : a:firstcol-1] : '')
                    \ . substitute(line[a:firstcol:], opt_comm, a:comm_char, "") )
            let linenum += 1
        endfor
    endif
endfunction

function! ToggleCommentVisual (comm_char, comm_delim, startline, endline, firstcol, lastcol) abort
    " Start at the first line...
    let linenum = a:startline

    " Get all the lines
    let currline = getline(a:startline, a:endline)

    " Delimiting comments available, so delimit the selection
    if (type(a:comm_delim) == type({}))
        let startlen = strchars(a:comm_delim.start)
        let endlen   = strchars(a:comm_delim.end)
        let commlen  = strchars(a:comm_char)
        if currline[0][a:firstcol : a:firstcol + startlen - 1] ==# a:comm_delim.start
        \ && currline[-1][a:lastcol - endlen + 1 : a:lastcol]  ==# a:comm_delim.end
            " If the first line is commented, decomment all...
            let currline[-1] = currline[-1][0 : a:lastcol-endlen]
                            \. currline[-1][a:lastcol+1 : -1]
            let currline[0] = (a:firstcol > 0 ? currline[0][0 : a:firstcol-1] : '')
                            \. currline[0][a:firstcol + startlen : -1          ]
            call setline(linenum,                     currline[0] )
            call setline(linenum + len(currline) - 1, currline[-1])
            return
        elseif currline[0][a:firstcol : a:firstcol + commlen - 1] !=# a:comm_char
            " Otherwise, encomment all...
            let currline[-1] = currline[-1][0 : a:lastcol]
                            \. a:comm_delim.end
                            \. currline[-1][a:lastcol+1 : -1]
            let currline[0] = (a:firstcol > 0 ? currline[0][0 : a:firstcol-1] : '')
                            \. a:comm_delim.start
                            \. currline[0][a:firstcol : -1 ]
            call setline(linenum,                     currline[0] )
            call setline(linenum + len(currline) - 1, currline[-1])
            return
        endif
    endif

    " Decide their comment state by examining the first line...
    if currline[0][a:firstcol : ] =~ '^' . a:comm_char
        " If the first line is commented, decomment all...
        call setline(linenum, currline[0][0 : a:firstcol-1]
                        \. substitute(currline[0][a:firstcol :], '^' . a:comm_char, "", ""))

        for line in currline[1:-1]
            let linenum += 1
            call setline(linenum, substitute(line, '^' . a:comm_char, "", "") )
        endfor

    else
        " Otherwise, encomment all...
        let opt_comm = '^\('. a:comm_char . '\)\?'
        if len(currline) == 1
            call setline(linenum, currline[0][0 : a:firstcol-1]
                            \. substitute(currline[0][a:firstcol : a:lastcol],
                                        \ opt_comm, a:comm_char, ""))
        else
            call setline(linenum, currline[0][0 : a:firstcol-1]
                            \. substitute(currline[0][a:firstcol :], opt_comm, a:comm_char, ""))

            for line in currline[1:-2]
                let linenum += 1
                call setline(linenum, substitute(line, opt_comm, a:comm_char, "") )
            endfor

            let linenum += 1
            call setline(linenum, substitute(currline[-1][0 : a:lastcol], opt_comm, a:comm_char, ""))
        endif

        if currline[-1][a:lastcol+1 :] =~ '\S'
            call append(linenum, repeat(' ', strchars(currline[-1][0 : a:lastcol]))
                            \. currline[-1][a:lastcol+1 :] )
        endif
    endif
endfunction

function! ToggleCommentVisualLine (comm_char, startline, endline) abort
    " Start at the first line...
    let linenum = a:startline

    " Get all the lines
    let currline = getline(a:startline, a:endline)

    " Decide their comment state by examining the first line...
    if currline[0] =~ '^' . a:comm_char
        " If the first line is commented, decomment all...
        for line in currline
            call setline(linenum, substitute(line, '^' . a:comm_char, "", "") )
            let linenum += 1
        endfor

    else
        " Otherwise, encomment all...
        let opt_comm = '^\('. a:comm_char . '\)\?'
        for line in currline
            call setline(linenum, substitute(line, opt_comm, a:comm_char, "") )
            let linenum += 1
        endfor
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo

