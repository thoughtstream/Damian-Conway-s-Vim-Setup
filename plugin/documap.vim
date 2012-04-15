" Vim global plugin for defining documented nmaps
" Last change:  Tue Oct 25 12:06:52 EST 2011
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_documap")
    finish
endif
let loaded_documap = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Interface ]================

" In your .vimrc:  Nmap <options> KEY  [DOC HERE]  EXPANSION HERE

command! -nargs=+ Nmap call <SID>Define('Nmap', <q-args>)


"=====[ Implementation ]================
"
" Remember the documentation for each mapping (with the trigger as the key)...
let s:MapDoc_Description = {}

" Parse Nmap specifications...
let s:mapdoc_syntax = '\C\(\%(\s*<[a-z]\+>\s*\)*\)\s*\(\S\+\)\s\+\%(\[\(.\{-}\)\]\)\?\(.*\)'

" Build the corresponding nmap and record the documentation...
function! s:Define (type, args)
    " Parse the specification (if possible)...
    try
        let [match, opts, lhs, desc, rhs; etc] = matchlist(a:args, s:mapdoc_syntax)
    " Otherwise report the failure...
    catch
        echoerr 'Invalid syntax in: ' . a:type . ' ' a:args
        return
    endtry

    " Report missing lhs to mapping...
    if lhs =~ '^[' && empty(desc)
        echoerr 'Missing lhs before description in: ' . a:type . ' ' . a:args
        return
    endif

    " Record the description...
    let s:MapDoc_Description[lhs] = empty(desc) ? '????' : desc

    " Build the actual mapping...
    exec tolower(a:type) . ' ' . opts . ' ' . lhs . ' ' . rhs
endfunction

" Display the list of known documented mappings...
function! s:ListMappings ()
    " Temporarily turn on paging...
    let old_more = &more
    set more

    " Print each lhs/description pair prettily...
    echohl MoreMsg
    echo repeat('_',80) "\n"
    for lhs in sort(keys(s:MapDoc_Description))
        echohl ModeMsg
        echon printf("%-4s ", lhs)
        echohl MoreMsg
        echon printf("%s", s:MapDoc_Description[lhs])
        echon "\n"
    endfor
    echo repeat('_',80)
    echohl None

    " Turn off temporary paging...
    if !old_more
        set nomore
    endif
endfunction


"=====[ More interface ]======

" Show the documented mappings while editing...

Nmap ;h [Print this list] :call <SID>ListMappings()<CR>


" Restore previous external compatibility options
let &cpo = s:save_cpo
