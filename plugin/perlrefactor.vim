" Vim global plugin for refactoring Perl code
" (Also requires the perl_refactor Perl script)
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

"Interface is <C-R> in visual mode...
xnoremap <silent> <C-R>  ygvs<C-R>=PerlRefactor_refactor()<CR><ESC>


" IMPLEMENTATION...

let s:MISSING_RETURN_STATEMENT = '# RETURN VALUE? MAYBE: \([^\n]*\)'

" Provide list of possible variables to complete return statement...
function! PerlRefactor_complete (ArgLead, CmdLine, CursorPos)
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
    let refactor = system('perl_refactor -n=' . newname, @@)

    " Extract the replacement call, and the sub definition...
    let lines = split(refactor, '\n', 'keepempties')
    let line1 = remove(lines, 0)
    let subcode = "\n" . join(lines, "\n")

    " Prompt for a return statement, if one seems to be needed...
    let return_candidates = matchlist(subcode, s:MISSING_RETURN_STATEMENT)
    if !empty(return_candidates)
        let b:PRcomplete_vars = substitute(return_candidates[1], ", ", "\n", "g")
        call inputsave()
        let return_val = input("Return statement: return ", "", 'custom,PerlRefactor_complete')
        call inputrestore()
        if !empty(return_val)
            let subcode = substitute(subcode, s:MISSING_RETURN_STATEMENT, 'return ' . return_val . ';', '')
        endif
    endif

    " Put the subroutine definition into the nameless and "s registers, ready for pasting
    let @@ = subcode . "\n"
    let @s = subcode . "\n"

    " Return the replacement code...
    return line1
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo

