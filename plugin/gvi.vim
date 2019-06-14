" Vim global plugin for enhanced lvimgrep (with shell support)
" Last change:  Wed Dec 21 07:07:18 AEDT 2016
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_GVI")
    finish
endif
let loaded_GVI = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"======[ Interface ]===========================================================
"
" Usage:
"
"      From the shell command-line:
"
"           > vim +'GVI -s /pattern/ [optional paths ...]'
"
"      From the Vim command-line:
"
"           :GVI /pattern/ [optional paths ...]
"
"
" Optional path list defaults to: ** (i.e. everywhere below the current directory)
"
" Also see the two global variables and two highlight groups below
"

" Set this true to use (faster, external) ag instead of (slower, internal) lvimgrep...
if !exists('g:GVI_use_ag')
    let g:GVI_use_ag = 0
endif

" Limit messages to this width...
if !exists('g:GVI_message_width')
    let g:GVI_message_width = 50
endif


" Default highlights...
highlight default  GVI_Match  ctermfg=LightBlue cterm=bold
highlight default  GVI_Error  ctermfg=red cterm=bold



"======[ Implementation "]======================================================

" Define the command...
command! -nargs=1  GVI  call GVI_Setup(<q-args>)


" Implement the command...
function! GVI_Setup(qargs)

    " Parse the command-line...
    let args = matchlist(a:qargs, '^\s*\(\%(-s\)\?\)\s*/\(\%(\\.\|[^\/]\)*\)/\s*\(.*\)$')

    " Give up immediately if the command-line doesn't make sense...
    if empty(args)
        call GVI_Fail('Invalid arguments to GVI: ' . a:qargs, a:qargs =~ '^\s*-s\>')
        return
    endif

    " Otherwise, unpack the arguments...
    let [fromshell, target, paths] = args[1:3]

    " Remove any shellish overquoting (e.g. /'pattern'/ or /\<pattern/)...
    if !empty(fromshell)
        let target = substitute(target, '^\([''"]\)\(\_.*\)\1$', '\2', '' )
        let target = substitute(target, '\\\@!\\\([<>]\)',       '\1', 'g')
    endif

    " Escape unescaped / to allow it to appear in the /pattern/ of lvimgrep...
    let target = substitute(target, '\\\@!/',              '\/', 'g')

    " Add smartcase-like case-sensitivity..
    let cs_target = (target =~ '\u' ? '\C' : '\c') . target

    " Default to searching everywhere (ag doesn't need a default path)...
    if empty(paths) && !g:GVI_use_ag
        let searchpath = '**'

    " If using ag, let it handle the unpacking of the search path...
    elseif g:GVI_use_ag
        let searchpath = paths

    " Otherwise we're using lvimgrep, so recursively search any specified directories
    else
        let searchpath = ''
        for arg in split(paths, '\s\+')
            for path in glob(arg,1,1,1)
                let searchpath .= (isdirectory(path) ? path . '/**' : path) . ' '
            endfor
        endfor
    endif

    " Execute the search...
    try
        if g:GVI_use_ag
            " Deploy ag via :make mechanism (silencing it and restoring afterwards)...
            let prevsettings = [&makeprg, &errorformat, &shellpipe]
            let &shellpipe   = '>'
            let &makeprg     = 'ag -S --vimgrep --silent --print-long-lines $*'
            let &errorformat = '%f:%l:%c:%m'

            silent exec "lmake '" . target . "' " . searchpath

            let [&makeprg, &errorformat, &shellpipe] = prevsettings
            let @/ = target

        else
            exec 'lvimgrep /' . cs_target . '/ ' . searchpath
            let @/ = cs_target

        endif
    catch
    finally
    endtry

    " Report and terminate if no matches...
    if empty(getloclist(0))
        call GVI_Fail('No match found for /' . target . '/', !empty(fromshell))
        return
    endif

    " Cause each jump through the location list to echo the current file...
    call setloclist( 0,
    \                map(getloclist(0),
    \                    { n, v -> extend( v, {'text' : GVI_TrimFilename(bufname(v.bufnr)) } ) }
    \                )
    \              )

    " Make sure the first message is echo'd correctly...
    redraw
    echo "(1 of " . len(getloclist(0)) . "): " . GVI_TrimFilename(expand('%'))

    " Highlight every match...
    call matchadd('GVI_Match', cs_target, 1000)

    " Raise an event that others can hook...
    if exists('#User#GVI_Start')
        doautocmd User GVI_Start
    endif
endfunction


" Tidy filepaths and make them fit within a reasonable message area...
function! GVI_TrimFilename (filename)
    let filename = substitute(a:filename, '//', '/', 'g')
    return (strchars(filename) > g:GVI_message_width ? '…' . filename[1-g:GVI_message_width : -1] : filename)
endfunction

" Print error messages (to terminal if called from shell)...
function! GVI_Fail (msg, fromshell)
    if a:fromshell
        exec "silent !echo " . shellescape(a:msg)
        quitall!
    else
        redraw!
        echohl GVI_Error
        echo a:msg
        echohl NONE
    endif
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
