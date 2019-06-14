" Vim global plugin for yanking or deleting all lines with a match
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

if exists("loaded_yankmatches")
    finish
endif
let loaded_yankmatches = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


" Originally just:
"       nmap <silent> dm  :g//delete<CR>
" But that doesn't retain all deletes in the nameless register
"
" Then:
"       nmap <silent> dm  :let @a = ""<CR>:g//delete A<CR>
" But that doesn't seem to work :-(
" So:


"====[ Interface ]====================================================
"
" Change these if you want different commands for the specified actions...
"
nmap <silent> dm  :     call ForAllMatches('delete', {})<CR>
nmap <silent> dim :     call ForAllMatches('delete', {'match_only':1})<CR>
nmap <silent> DM  :     call ForAllMatches('delete', {'inverse':1})<CR>
nmap <silent> ym  :     call ForAllMatches('yank',   {})<CR>
nmap <silent> YM  :     call ForAllMatches('yank',   {'inverse':1})<CR>
nmap <silent> yim :     call ForAllMatches('yank',   {'match_only':1})<CR>

xmap <silent> dm  :<C-U>call ForAllMatches('delete', {'visual':1})<CR>
xmap <silent> dim :<C-U>call ForAllMatches('delete', {'visual':1, 'match_only':1})<CR>
xmap <silent> DM  :<C-U>call ForAllMatches('delete', {'visual':1, 'inverse':1})<CR>
xmap <silent> ym  :<C-U>call ForAllMatches('yank',   {'visual':1})<CR>
xmap <silent> yim :<C-U>call ForAllMatches('yank',   {'visual':1, 'match_only':1})<CR>
xmap <silent> YM  :<C-U>call ForAllMatches('yank',   {'visual':1, 'inverse':1})<CR>

function! ForAllMatches (command, options)
    " Remember where we parked...
    let orig_pos = getpos('.')

    " Work out the implied range of lines to consider...
    let in_visual = get(a:options, 'visual', 0)
    let start_line = in_visual ? getpos("'<'")[1] : 1
    let end_line   = in_visual ? getpos("'>'")[1] : line('$')

    " Are we inverting the selection???
    let inverted = get(a:options, 'inverse', 0)

    " Are we keeping only the matched text???
    let match_only = get(a:options, 'match_only', 0)

    " Are we modifying the buffer???
    let deleting = a:command == 'delete'

    " Honour smartcase (which :lvimgrep doesn't, by default)
    let sensitive = &ignorecase && &smartcase && @/ =~ '\u' ? '\C' : ''

    " No match? Then nothing to do...
    if !search(sensitive . @/, 'nwc')
        redraw
        unsilent echo 'Nothing to ' . a:command . ' (no matches found for /'. @/ .'/)'
        return
    endif

    " Identify the lines to be operated on...
    exec 'silent lvimgrep /' . sensitive . @/ . '/j %'
    let matched_line_nums
    \ = reverse(filter(map(getloclist(0), 'v:val.lnum'), 'start_line <= v:val && v:val <= end_line'))

    " Invert the list of lines, if requested...
    if inverted
        let inverted_line_nums = range(start_line, end_line)
        for line_num in matched_line_nums
            call remove(inverted_line_nums, line_num-start_line)
        endfor
        let matched_line_nums = reverse(inverted_line_nums)
    endif

    " Filter the original lines...
    let yanked = ""
    let submatch_count = 0
    for line_num in matched_line_nums
        " Remember yanks or deletions...
        let next_line = getline(line_num)
        if match_only
            let pos = 0
            let matched_strs = ""
            while pos < strlen(next_line)
                let [nextmatch, from, to] = matchstrpos(next_line, sensitive . @/, pos)
                if from < 0
                    break
                endif
                let pos = to + 1
                let matched_strs .= nextmatch . "\n"
                let submatch_count += 1
            endwhile
            let matched_strs = substitute(matched_strs, '\n$', '', '')
        else
            let matched_strs = next_line
        endif
        let yanked = matched_strs . "\n" . yanked

        " Delete buffer lines if necessary...
        if deleting
            if match_only
                exec 'silent ' . line_num . 's/' . sensitive . @/ . '//g'
            else
                exec line_num . 'delete'
            endif
        endif
    endfor

    " Make yanked lines available for putting...
    " previously just let @" = yanked
    if !exists('g:YankMatches#ClipboardRegister')
        let l:clipboard_flags = split(&clipboard, ',')
        if index(l:clipboard_flags, 'unnamedplus') >= 0
            let g:YankMatches#ClipboardRegister='+'
        elseif index(l:clipboard_flags, 'unnamed') >= 0
            let g:YankMatches#ClipboardRegister='*'
        else
            let g:YankMatches#ClipboardRegister='"'
        endif
    endif
    let l:command = ':let @' . g:YankMatches#ClipboardRegister . ' = yanked'
    execute 'normal! ' . l:command . "\<cr>"

    " Return to original position...
    call setpos('.', orig_pos)

    " Report results...
    redraw
    let match_count = len(matched_line_nums)
    if match_count == 0
        unsilent echo 'Nothing to ' . a:command . ' (no matches found for /'. @/ .'/)'
    elseif match_only && deleting
        unsilent echo submatch_count . ' match' . (submatch_count > 1 ? 'es' : '')
        \           . ' on ' . match_count . ' line' . (match_count > 1 ? 's' : '') . ' deleted'
    elseif match_only
        unsilent echo submatch_count . ' match' . (submatch_count > 1 ? 'es' : '')
        \           . ' on ' . match_count . ' line' . (match_count > 1 ? 's' : '') . ' yanked'
    elseif deleting
        unsilent echo match_count . (match_count > 1 ? ' fewer lines' : ' less line')
    else
        unsilent echo match_count . ' line' . (match_count > 1 ? 's' : '') . ' yanked'
    endif
endfunction
