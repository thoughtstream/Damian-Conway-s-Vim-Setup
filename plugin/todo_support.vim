" Vim global plugin for nicer ToDo files
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_TODO_SUPPORT")
    finish
endif
let loaded_TODO_SUPPORT = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


" Specify the default allowed bullets (and how to match them)...
let g:TODO_BULLETS    = exists('g:TODO_BULLETS') ? g:TODO_BULLETS : ['>', '*', '-', '+']
let g:TODO_BULLET_PAT = '[' . escape(join(g:TODO_BULLETS,''),'-]^\\') . ']'


" Load features for any TODO file...
augroup TODO_SUPPORT
    autocmd!
    autocmd BufNewFile,BufRead  *.todo,todo,ToDo,TODO   setfiletype todo
    autocmd BufEnter            *.todo,todo,ToDo,TODO   call TODO_Load_Support()
augroup END

" Set up the support features...
function! TODO_Load_Support ()
    " Shifts cause rebulleting...
    nnoremap <silent><buffer>  <<  <<:call TODO_Rebullet(line('.'), line('.'))<CR>
    nnoremap <silent><buffer>  >>  >>:call TODO_Rebullet(line('.'), line('.'))<CR>

    " These motions after a shift, delete, etc. rebullet the entire file...
    omap <silent><buffer>   G   G<TAB>
    omap <silent><buffer>   }   }<TAB>
    omap <silent><buffer>   {   {<TAB>
    omap <silent><buffer>   )   )<TAB>
    omap <silent><buffer>   (   (<TAB>

    " <TAB> rebullets the entire file...
    nmap <silent><buffer>      <TAB> :call TODO_Rebullet(1, line('$'))<CR>

    " Shifting visual regions cause rebulleting and reselection...
    xnoremap <silent><buffer>   >  >:call TODO_RebulletVisual()<CR>gv
    xnoremap <silent><buffer>   <  <:call TODO_RebulletVisual()<CR>gv

    " Next line is always indented past the bullet...
    inoremap <expr><buffer> <CR> TODO_IndentLine()

    " Inserting a bullet, causes it to be correctly re-indented
    for bullet in g:TODO_BULLETS
        exec 'inoremap <expr><buffer>   ' . bullet . "  TODO_ReindentLine('". bullet . "')"
    endfor

    " Ignore spaces immediately after a bullet...
    inoremap <expr><buffer>   <SPACE>   TODO_LimitTrailingSpace(' ')

    " Big-D deletes the entire point including subpoints...
    nnoremap <silent><buffer>  DD  :call TODO_DeletePoint()<CR>

    " Folding is determined by indentation (but never on by default)...
    setlocal foldminlines=0
    setlocal foldtext=TODO_FoldText()
    setlocal foldmethod=indent
    %foldopen!
endfunction

" Delete a point (and subpoints)...
function! TODO_DeletePoint ()
    " Should we delete trailing whitespace (not if preceding line has text)???
    let prevline = getline(line('.')-1)
    let delete_trailing = prevline !~ '\S'

    " Retrieve and remove current line...
    let currline = getline('.')
    delete

    " Determine minimum indent to delete...
    let indent = matchstr(currline, '^\s*')

    " Delete all successive non-blank lines with more than that much indent...
    let nextline = getline('.')
    while nextline =~ '\S' && nextline =~ '^'.indent.' '
        delete
        let nextline = getline('.')
    endwhile

    " Delete trailing blank lines (maybe)...
    while delete_trailing && nextline =~ '^\s*$'
        delete
        let nextline = getline('.')
        if line('.') == line('$')
            break
        endif
    endwhile

endfunction

" Prevent extra spaces after bullets...
function! TODO_LimitTrailingSpace (possible_char)
    let currline = getline('.')
    if currline =~ '^\s*'.g:TODO_BULLET_PAT.'\s$'
        return ""
    else
        return a:possible_char
    endif
endfunction

" Add an indent on lines following a bullet...
function! TODO_IndentLine ()
    let prevline = getline('.')

    " Is this a blank line we're terminating (if so, make it empty)...
    let clear_blank_line = prevline =~ '^\s\+$' ? "\<C-U>" : ""
    let duplicate_indent = prevline =~ '^\s\+$' ? prevline : ""

    " Is this a bulleted line we're terminating (if som indent the next line)...
    let add_indent = prevline =~ '^\s*[>*\-+]\s\+' ? "  " : ""

    return clear_blank_line . "\<CR>" . duplicate_indent . add_indent
endfunction

" Change the indent if a leading bullet is used...
function! TODO_ReindentLine (bullet)
    " If bullet is leading, find which bullet it is...
    if getline('.') !~ '\S'
        for bullet_index in range(len(g:TODO_BULLETS))
            if a:bullet == g:TODO_BULLETS[bullet_index]
                " ...and return a re-indented bullet...
                return "\<C-U>" . repeat(' ', &shiftwidth * bullet_index) . a:bullet . " "
            endif
        endfor

    " Otherwise just echo the bullet...
    else
        return a:bullet
    endif
endfunction

" How to rebullet an entire visually selected range...
function! TODO_RebulletVisual ()
    " Locate the visually selected lines...
    let left_pos  = getpos("'<")
    let right_pos = getpos("'>")

    " Rebullet them...
    if len(left_pos)
        call TODO_Rebullet(min([left_pos[1], right_pos[1]]), max([left_pos[1],right_pos[1]]))
    endif
endfunction

" How to rebullet a specific range of lines...
function! TODO_Rebullet(fromline, toline)
    " Reformat each line in the range...
    for linenum in range(a:fromline, a:toline)
        let line = getline(linenum)

        " Parse line...
        let matchlist_results = matchlist(line, '^\(\s*\)\('.g:TODO_BULLET_PAT.'\)\(\s.*\)')

        " Ignore unbulleted lines...
        if len(matchlist_results) < 4
            continue

        " Extract components of bulleted line...
        else
            let [ws, bullet, etc] = matchlist_results[1:3]
        endif

        " Determine correct bullet for indentation level...
        let new_bullet_level = strlen(ws) / &shiftwidth
        let new_bullet = g:TODO_BULLETS[new_bullet_level % len(g:TODO_BULLETS)]

        " Rewrite line with that bullet...
        call setline(linenum, ws . new_bullet . etc)
    endfor
endfunction

" How to generate the fold marker for a giving level of folding...
function! TODO_FoldText()
    " Determine folidng level and bullet to look for...
    let foldlevel  = strlen(v:folddashes)
    let foldbullet = g:TODO_BULLETS[foldlevel % len(g:TODO_BULLETS)]

    " Create pattern to locate top-level folded bullets...
    let foldindent = matchstr(getline(v:foldstart), '^\s\+\V'.foldbullet)

    " Extract and compact bullet points to be folded...
    let folded_points = filter(getline(v:foldstart, v:foldend), "v:val =~ '^\\V'.foldindent")
    call map(folded_points, "substitute(v:val,'^\\s*','','')")
    call map(folded_points, "strlen(v:val)>20 ? strpart(v:val,0,17).'...' : strpart(v:val,0,20)")
    call map(folded_points, "substitute(v:val,'\\s\\+\\.\\.\\.$','...','')")

    " Construct fold text from compacted bullets...
    let foldtext = repeat("    ", foldlevel)
    \            . join(folded_points, "   ")
    \            . repeat(" ", 1000)

    return foldtext
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
