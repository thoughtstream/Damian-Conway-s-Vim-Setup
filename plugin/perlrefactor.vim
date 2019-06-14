" Vim global plugin for refactoring Perl code
"
" Last change:  Wed May 24 12:26:16 CEST 2017

" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_perlrefactor")
    finish
endif
let loaded_perlrefactor = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Refactor a visual block of Perl code ]===============

" INTERFACE...

" Select code and press <C-R> in visual mode...

xnoremap <silent><expr> <PLUG>GrabAndRefactor  <SID>grab_and_refactor()

xmap <silent> <C-R> "ry`>/[^\s,]<CR>"tyl`<?\S<CR>"lyl:nohls<CR>gv<PLUG>GrabAndRefactor


" Set this highlight to change the colour of error messages...
"
highlight default Perlrefactor_Error  ctermfg=Red cterm=Bold


" Set this string to configure the refactorer...
" For example:
"
" let g:Perlrefactor_options = "builder => 'Signatures', name => 'FOO'"



" IMPLEMENTATION...

let s:MISSING_RETURN_STATEMENT = '# RETURN VALUE HERE? MAYBE: \([^\n]*\)'

" Provide list of possible variables to complete return statement...
function! Perlrefactor_complete (ArgLead, CmdLine, CursorPos)
    return b:PRcomplete_vars
endfunction

" Do the refactoring...
function! PerlRefactor_refactor ()
    " Get the new sub's name...
    call inputsave()
    let newname = input("Refactor as: sub ")
    call inputrestore()
    if empty(newname)
        let newname = '___SUBNAME___'
    endif

    " Call the perl script that does the hard work...
    let options = '{ name => q{' . newname . '}, '
    \           . '  leading  => q{' . escape(@l,'{}') . '}, '
    \           . '  trailing => q{' . escape(@t,'{}') . '}, '
    \           .    get(g:, 'Perlrefactor_options', '')
    \           . '}'
    let refactored = system("perl -MCode::Refactor -e 'refactor_for_Vim(" . options . ")'", @r)
    let lines = split(refactored, '\n', 'keepempties')
    let refactored_call = remove(lines, 0)
    let refactored_code = "\n" . join(lines, "\n")

    if refactored_call =~ '^#'
        echohl  Perlrefactor_Error
        echomsg strcharpart(refactored_call,1)
        echohl  NONE
        return "\<ESC>:silent normal u<CR>"
    endif

    " Prompt for a return statement, if one seems to be needed...
    let return_candidates = matchlist(refactored_code, s:MISSING_RETURN_STATEMENT)
    if !empty(return_candidates)
        let b:PRcomplete_vars = substitute(return_candidates[1], ", ", "\n", "g")
        call inputsave()
        let return_val = input("Return statement: return ", "", "custom,Perlrefactor_complete")
        call inputrestore()
        if !empty(return_val)
            let refactored_code
            \   = substitute(refactored_code,
            \                s:MISSING_RETURN_STATEMENT,
            \                'return ' . escape(return_val,'\') . ';', '')
        else
            let refactored_code
            \   = substitute(refactored_code, '\_s*'.s:MISSING_RETURN_STATEMENT, "\n", '')
        endif
    endif

    " Put the subroutine definition into the nameless and "s registers, ready for pasting
    let @" = refactored_code . "\n"
    let @s = refactored_code . "\n"

    " Return the replacement code...
    return refactored_call
endfunction

" Choose the correct replacement mode for various visual modes...
function! s:grab_and_refactor()
    return ( @r =~ '\n' && visualmode() == "\<C-V>" ? 'v"rygvs' : 's' )
    \    . "\<C-R>=PerlRefactor_refactor()\<CR>\<ESC>"
endfunction



" Restore previous external compatibility options
let &cpo = s:save_cpo

