" Vim global plugin for list format translations
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

"######################################################################
"##                                                                  ##
"##  To use:                                                         ##
"##                                                                  ##
"##     nmap <SOMEKEY>  :call ListTrans_toggle_format()<CR>          ##
"##     xmap <SOMEKEY>  :call ListTrans_toggle_format('visual')<CR>  ##
"##                                                                  ##
"##  For example:                                                    ##
"##                                                                  ##
"##     nmap  ;l   :call ListTrans_toggle_format()<CR>               ##
"##     xmap  ;l   :call ListTrans_toggle_format('visual')<CR>       ##
"##                                                                  ##
"######################################################################


" If already loaded, we're done...
if exists("loaded_listtrans")
    finish
endif
let loaded_listtrans = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Useful constants...
let g:LT_DEF_LIST_CONJ = 'and'
let g:LT_CONJUNCTIONS  = [
\   'and\s\+not', 'and', 'plus', 'with',
\   'or\s\+else', 'or\s\+otherwise',
\   'or', 'nor', 'but\s\+not', 'but', 
\   'else', 'otherwise'
\]

" Build the necessary pattern...
let s:LT_CONJ_PAT = join(g:LT_CONJUNCTIONS, '\|')

" This is the entire interface...
function! ListTrans_toggle_format (...) range
    " Extract the target text...
    if a:0
        silent normal! gvy
    else
        silent normal! vipy
    endif
    let text = getreg("")

    " Remember the indent and any bullet...
    let [match, indent, bullet; etc] = matchlist(text, '^\(\s*\)\([^A-Za-z \t]*\s*\)')

    " If it starts with a bullet, are there more bullets???
    if strlen(bullet) > 0
        let items = split(substitute(text,'^\s*\V'.bullet,'',''), '\n\s*\V'.bullet)
        call map(items, 'substitute(v:val,''[[:space:]]\+''," ","g")')
        call map(items, 'substitute(v:val,''[[:space:]]$'',"","")')

        " If two or more bulleted items, it's bullet list --> text list...
        if len(items) >= 2
            " Infer the correct conjunction...
            let has_conj = matchlist(items[-2], '^\(\_.\{-}\)[,;]\?\s*\('.s:LT_CONJ_PAT.'\)\s*$')
            let [items[-2], conj] = len(has_conj) ? has_conj[1:2] : [items[-2], g:LT_DEF_LIST_CONJ]

            " Conjoin the various items (using Oxford rules)...
            if len(items) == 2
                let sep  = len(filter(copy(items), 'v:val =~ ","')) ? ', ' : ' '
                let reformatted_text = indent . join(items, sep.conj.' ')
            else
                let sep  = len(filter(copy(items), 'v:val =~ ","')) ? '; ' : ', '
                let reformatted_text = indent . join(items[0:-2], sep)
                                   \ . sep . conj . ' '
                                   \ . items[-1]
            endif

            " Paste back into buffer in place of original...
            call setreg("", reformatted_text, mode())
            silent normal! gv""p
            return
        endif
    endif

    " Otherwise, it's text list --> bullet list...

    " Identify and remove initial indent...
    let [match, indent, text; etc] = matchlist(text, '^\(\s*\)\(\_.*\)')

    " Minimize whitespace...
    let text = substitute(text,'[[:space:]]\+'," ",'g')
    let text = substitute(text,'[[:space:]]\+$','','')

    " Identify most likely separator...
    let sep = text =~ ';' ? '\s*;\s*'
          \ : text =~ ',' ? '\s*,\s*'
          \ :               '\s\+\(' . s:LT_CONJ_PAT . '\)\s\+'

    " Separate...
    let items = split(text, sep)

    " Check for an extra conjunction in the last item...
    let last_item = remove(items, -1)
    let last_sep = matchstr(last_item, '^\s*\(' . s:LT_CONJ_PAT . '\)\>\s*')
    if strlen(last_sep)
        let [last_item] = split(last_item, '\s*\(' . s:LT_CONJ_PAT . '\)\s\+')
        if last_sep !~ '^\s*\(and\|plus\)'
            let items[-1] .= ', ' . last_sep
        endif
    endif
    let items += [last_item]

    " Rejoin and paste back into buffer in place of original...
    let reformatted_text = join(map(items, 'indent."- ".v:val."\n"'), "")
    call setreg("", reformatted_text, mode())
    silent normal! gv""p

endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
