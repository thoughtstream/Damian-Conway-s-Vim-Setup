" Vim global plugin for semi-auto completion on file changes
" Last change:  Sat Jul 12 18:52:27 PDT 2014
" Maintainer:   Damian Conway
" License:  This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_GTF")
    finish
endif
let loaded_GTF = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ INTERFACE ]================================================

" Default colour scheme...
highlight default  GTF_CANCELLED  ctermfg=magenta
highlight default  GTF_LOOKAHEAD  ctermfg=blue
highlight default  GTF_NEW        ctermfg=cyan

" How many lines of completions to auto-show...
let g:GTF_SHOW_COMPLETIONS = 1

" How to display completion sets...
let g:GTF_COMPLETION_LINES = 20
let g:GTF_COMPLETION_COLS  = 80
let g:GTF_COMPLETION_GAP   = 3


" Call this to accept filenames and go to them...
function! g:GTF_goto_file ()
    " Prepare context...
    let file_list = glob('*',0,1)
    let input     = ''
    let status    = 'multi'

    " Suspend communication with Vim...
    call inputsave()

    " Read in filenames...
    while 1
        " Split input into already-processed and still-being-processed...
        let input_processed = matchstr(input, '^.*\s\+')
        let input_active    = input[len(input_processed):]

        " Indicate current status...
        redraw
        if status == 'unique'
            " Infer the unique completion...
            let prefix     = file_list[0][0:len(input_active)-1]
            let completion = file_list[0][len(input_active):]

            " Show the command...
            echo 'Go to: ' . input_processed . prefix
            echohl GTF_LOOKAHEAD
            echon completion
            echohl None
            echon "\rGo to: " . input_processed . prefix

        elseif status == 'new'
            " Show the command...
            echo 'Go to: ' . input_processed
            echohl GTF_NEW
            echon input_active

        else " status == 'multi'
            " Tabulate possible completions (if there are few enough to show)...
            let completions = s:completion_table_for(file_list)
            if len(completions) <= g:GTF_SHOW_COMPLETIONS
                echohl GTF_LOOKAHEAD
                for completion in completions
                    echon "\n" . completion
                endfor
            endif

            "Show the command...
            echohl None
            echon "\n" .'Go to: ' . input_processed . input_active
            echohl GTF_LOOKAHEAD
            echon '   <' . len(file_list) . '>'
            echohl None
            echon "\rGo to: " . input_processed . input_active
        endif
        echohl None

        " Accept another character...
        let next_char = s:active_getchar()

        " Tab --> accept completion(s)...
        if next_char == "\<TAB>"
            if status == 'unique'
                let input .= completion
                let input_active .= completion
                let next_char = (getftype(glob(file_list[0])) == 'dir' ? '' : ' ')

            elseif status == 'multi'
                let [selection, next_char] = s:cycle('Go to: ' . input_processed, file_list)
                let input = input_processed . selection
                let input_active = selection
            endif
        endif

        " <ESC> --> cancel...
        if next_char == "\<ESC>"
            let input = ""
            break
        endif

        " <CR> --> finish up and go...
        if next_char == "\<CR>"
            if status == 'unique'
                let input .= completion
            elseif status == 'multi' && input =~ '\S'
                let input .= '*'
            endif
            break
        endif

        " <BS> --> delete...
        if next_char == "\<BS>"
            let input        = input[0:-2]
            let input_active = input_active[0:-2]

        " Anything else --> normal input...
        else
            let input        .= next_char
            let input_active .= next_char
        endif

        " Work out the new list of compatible files...
        let file_list = glob(input_active =~ '\*$' ? input_active : input_active.'*', 0, 1)
        if input_active[0] == '~'
            let file_list = map(file_list, 'substitute(v:val, "^".$HOME, "\\~", "")')
        endif
        let file_list = map(file_list, 'getftype(v:val) == "dir" ? v:val."/" : v:val')
        let file_list = s:simplify_completions(file_list)

        " Work out what that list implies...
        if len(file_list) == 0
            let status = 'new'
        elseif len(file_list) == 1
            let status = 'unique'
        else
            let status = 'multi'
        endif
    endwhile

    " Restore communication with Vim...
    call inputrestore()

    " No input --> no goto...
    if input =~ '^\s*$'
        echohl GTF_CANCELLED
        redraw
        echo '[Cancelled]'
        return ":redraw\<CR>"
    endif

    " Expand specifications...
    let file_list = []
    for glob_pat in split(input)
        " Is it an existing file (or files)...
        let matches = glob(glob_pat, 0, 1)

        " If so, take all...
        if len(matches)
            let file_list += matches

        " Otherwise, take it if it's not globby...
        elseif glob_pat !~ '[][*]'
            let file_list += [glob_pat]
        endif
    endfor

    " Clean up the status line (and thwart annoying pauses)...
    redraw

    " Prepare and serve a delicious feast of files...
    return ':next ' . join(file_list,  ' ') . " %\<CR>"
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo




"=====[ IMPLEMENTION ]================================================

" Overcome inconsistent getchar() behaviour...
function! s:active_getchar ()
    " Get a character, ignoring annoying timeouts...
    let char = 0
    while !char
        let char = getchar(1)
    endwhile
    call getchar(0)

    " Translate <DELETE>'s...
    if char == 128
        return "\<BS>"

    " Translate everything else...
    else 
        return nr2char(char)
    endif
endfunction


" Build a table of completion possibilities to display...
function! s:completion_table_for (file_list)
    " Precalculate column separator...
    let COMPL_SEP   = repeat(' ', g:GTF_COMPLETION_GAP)

    let list = map(copy(a:file_list), 'substitute(v:val, ".*/\\ze.", "", "")')

    " Spread them across as few lines as possible (starting with 1)...
    for max_lines in range(1,g:GTF_COMPLETION_LINES)
        " Set up an empty table of a minimal number of lines...
        let completions = repeat([""], max_lines)

        " Attempt to fill in the table column-by-column...
        let idx = 0
        for file in list
            " Add the filename to the next column...
            let completions[idx] .= file . COMPL_SEP

            " Move to the next line (or back to the next column)...
            let idx = (idx + 1 ) % max_lines
            if idx == 0
                " At which point calculate the previous column's width...
                let max_width = max(map(copy(completions), 'len(v:val)'))

                " If no width left, restart with an extra line...
                let margin = g:GTF_COMPLETION_COLS - max_width
                if margin < 0
                    break
                endif

                " Otherwise, pad the recently completed column...
                let completions = map(completions, 'printf("%-'.max_width.'s", v:val)')
            endif
        endfor

        " If we had space to spare, we're done...
        if margin > 0
            break
        endif
    endfor

    " Too much to show, so show nothing...
    if margin < 0 
        return []
    endif

    " If we processed everything, resturn it all...
    return completions
endfunction

" Compute the common prefix of a set of file_names...
function! s:common_prefix (file_list)
    let list = copy(a:file_list)

    " The common prefix won't be any longer than the shortest name...
    let maxlen = min(map(copy(list),'len(v:val)')) - 1

    " And it has to (partially) match the first filename...
    let common = remove(list, 0)[0:maxlen]

    " Go through the rest...
    for next in list
        while maxlen >= 0
            " Reduce the length of the common prefix if there's a mismatch...
            if common[0:maxlen] !=? next[0:maxlen]
                let maxlen -= 1

            " Otherwise, this filename shares the common prefix..
            else
                break
            endif
        endwhile

        " We can stop as soon as there's no common prefix...
        if maxlen < 0
            return ""
        endif
    endfor

    " If we match every entry, we've found the commonality...
    return common[0:maxlen]
endfunction

" Cycle through a list of completions, as long as the user <TAB>'s...
function! s:cycle (prefix, file_list)
    " Set up the queue and the slops bucket...
    let common = s:common_prefix(a:file_list)
    let list = [common] + copy(a:file_list)
    let shown_list = []

    " Cycle endlessly...
    while 1
        " If we ran out, cycle back...
        if !len(list)
            let list = shown_list
            let shown_list = []
        endif

        " Select the next alternative...
        let selection = remove(list,0)
        let shown_list += [selection]

        " Display it...
        redraw
        let completions = s:completion_table_for(a:file_list)
        if len(completions)
            echohl GTF_LOOKAHEAD
            for completion in completions
                echon "\n" . completion
            endfor
        endif
        echohl None
        echon "\n" . a:prefix . selection

        " Get some response...
        let next_char = s:active_getchar()

        " We keep cycling on successive tabs...
        if next_char != "\<TAB>"
            break
        endif
    endwhile

    " Report the outcome...
    return [selection, next_char]
endfunction

" Extend a unique completion through as many equally unique subdirs as possible...
function! s:simplify_completions (file_list)
    let list = copy(a:file_list)
    let prev_list = copy(list)

    " Drop through singleton subdirectories...
    while len(list) == 1 && list[0] =~ '/$'
        let prev_list = copy(list)
        let list = glob(list[0].'*', 0, 1)
        let list = map(list, 'getftype(v:val) == "dir" ? v:val."/" : v:val')
    endwhile

    " Return final level that was still singleton...
    return (len(list) == 1 ? list : prev_list)
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
