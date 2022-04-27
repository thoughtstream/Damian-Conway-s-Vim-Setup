" Vim global plugin for replacing input() with something better
"
" Last change:  2020-05-26T01:47:39+0000
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_ask")
    finish
endif
let loaded_ask = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Default highlight groups
highlight default AskPrompt  ctermfg=white cterm=bold
highlight default AskDefault ctermfg=blue  cterm=bold,italic
highlight default AskInput   ctermfg=cyan

" Get a character, ignoring annoying timeouts...
function! s:active_getchar () abort

    " Is there anything to get...
    let char = getchar()

    " Skip any CursorHold timeouts, by rechecking...
    while char == "\<CursorHold>"
      let char = getchar()
    endwhile

    " Translate <DELETE>'s...
    if char == 128 || char == "\<BS>"
        return "\<BS>"
    endif

    " See if we got a single character, otherwise return the lot...
    let single_char = nr2char(char)
    return empty(single_char) ? char : single_char
endfunction

" Like the built-in input() function, only prettier and smarter...
function! Ask (prompt, ...) abort
    " Remember where we parked...
    call inputsave()

    " Clean up the prompt...
    let preprompt = split(substitute(a:prompt, '\s*$', ' ', ''), "\n", 1)
    let prompt = remove(preprompt, -1)
    let default = get(a:000,0,'')

    " Echo it, with any default in a different colour
    echohl AskPrompt
    for line in preprompt
        echo line
    endfor

    echohl AskDefault
    echo prompt . default
    echohl AskPrompt
    echon "\r" . prompt
    echohl NONE
    let first = 1
    let input = ''
    while 1
        let next_char = s:active_getchar()
        if first
            echohl AskPrompt
            echon "\r" . prompt . repeat(' ', strchars(default))
            echon "\r" . prompt
            echohl NONE
            let first = 0
        endif
        if next_char == "\<ESC>" || next_char == "\<C-C>"
            call inputrestore()
            return next_char
        elseif next_char == "\<BS>"
            let input = strpart(input,0,strchars(input)-1)
            echohl AskPrompt
            echon "\r" . prompt
            echohl AskInput
            echon input . ' '
            echohl NONE
        elseif next_char == "\<CR>"
            call inputrestore()
            return (strchars(input) ? input : default)
        else
            let input .= next_char
        endif

        " Redraw default if no input...
        if strchars(input) == 0
            echohl AskDefault
            echon "\r" . prompt . default
        endif

        " Redraw prompt and any input...
        echohl AskPrompt
        echon "\r" . prompt
        if strchars(input) > 0
            echohl AskInput
            echon input
        endif
        echohl NONE
    endwhile
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo

