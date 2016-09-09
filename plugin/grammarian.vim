" Vim global plugin for grammar checking
" License:      This file is placed in the public domain.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  This plugin provides access to the grammar-checking functionality of the
"  Perl module Lingua::EN::Grammarian, from within Vim.
"
"  It defines a single nmap: ;g
"  which toggles grammar checking on the current buffer.
"
"  When grammar checking is activated, two additional nmaps are defined:
"
"      <TAB>      : which jumps to and describes the next error 
"      <S-TAB>    : which corrects the error under the cursor
"
"  These mappings are reverted to their former behaviours
"  (as far as possible) when grammar checking is toggled back off.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" If already loaded, we're done...
if exists("loaded_grammarian")
    finish
endif
let loaded_grammarian = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


" Create a pattern that matches repeated words...
let s:REPEAT_MATCHER = '\c\(\<\S\+\>\)\@>\_s\+\<\1\>'

" Display cautions and errors and messages...
highlight GRAMMARIAN_BOLD           term=bold cterm=bold                               gui=bold
highlight GRAMMARIAN_WHITE          term=bold cterm=bold ctermfg=white                 gui=bold guifg=white
highlight GRAMMARIAN_GREEN          term=bold cterm=bold ctermfg=green                 gui=bold guifg=green
highlight GRAMMARIAN_YELLOW         term=bold cterm=bold ctermfg=yellow                gui=bold guifg=yellow
highlight GRAMMARIAN_CYAN           term=bold cterm=bold ctermfg=cyan                  gui=bold guifg=cyan
highlight GRAMMARIAN_RED            term=bold cterm=bold ctermfg=red                   gui=bold guifg=red
highlight GRAMMARIAN_RED_ON_YELLOW  term=bold cterm=bold ctermfg=red   ctermbg=yellow  gui=bold guifg=red
highlight GRAMMARIAN_RED_ON_WHITE   term=bold cterm=bold ctermfg=red   ctermbg=white   gui=bold guifg=red
highlight GRAMMARIAN_WHITE_ON_RED   term=bold cterm=bold ctermfg=white ctermbg=red     gui=bold guifg=white guibg=red

highlight link GRAMMARIAN_ERROR_DISPLAY             GRAMMARIAN_WHITE_ON_RED
highlight link GRAMMARIAN_REPETITION_DISPLAY        GRAMMARIAN_RED_ON_YELLOW
highlight link GRAMMARIAN_CAUTION_DISPLAY           GRAMMARIAN_BOLD
highlight link GRAMMARIAN_ACTIVE_DISPLAY            GRAMMARIAN_RED_ON_WHITE

highlight link GRAMMARIAN_ERROR_MSG                 GRAMMARIAN_ERROR_DISPLAY
highlight link GRAMMARIAN_REPETITION_MSG            GRAMMARIAN_REPETITION_DISPLAY
highlight link GRAMMARIAN_CAUTION_MSG               GRAMMARIAN_CAUTION_DISPLAY
highlight link GRAMMARIAN_INFORMATION_MSG           GRAMMARIAN_WHITE
highlight link GRAMMARIAN_SUGGESTION_MSG            GRAMMARIAN_CYAN
highlight link GRAMMARIAN_SUGGESTION_DEFAULT_MSG    GRAMMARIAN_YELLOW

highlight link GRAMMARIAN_DECORATION                GRAMMARIAN_GREEN
highlight link GRAMMARIAN_PROMPT_MSG                GRAMMARIAN_GREEN

highlight link GRAMMARIAN_OLD_SPELLBAD              SpellBad


" Internal state information...
let s:grammarian_query_type       = ''
let s:grammarian_active_highlight = 0
let s:grammarian_restore          = {}
let s:grammarian_prev_match_pos   = [0,0,0,0]
let g:grammarian_explanations     = {}
let g:grammarian_suggestions      = {}

" Extra highlighting for active matches
let s:GRAMMARIAN_ACTIVE_DISPLAY_ID     = matchadd('GRAMMARIAN_ACTIVE_DISPLAY',    'x\@!x')
let s:GRAMMARIAN_REPETITION_DISPLAY_ID = matchadd('GRAMMARIAN_REPETITION_DISPLAY','x\@!x')

" Is error file up-to-date???
function! s:recompile_spelling_files ()
    if !filereadable('/Users/damian/.vim/grammarian/errors/spell/en.latin1.add.spl')
        exec 'mkspell /Users/damian/.vim/grammarian/errors/spell/en.latin1.add'
    endif
    if !filereadable('/Users/damian/.vim/grammarian/cautions/spell/en.latin1.add.spl')
        exec 'mkspell /Users/damian/.vim/grammarian/cautions/spell/en.latin1.add'
    endif
    if !filereadable('/Users/damian/.vim/grammarian/errors/spell/en.utf-8.add.spl')
        exec 'mkspell /Users/damian/.vim/grammarian/errors/spell/en.utf-8.add'
    endif
    if !filereadable('/Users/damian/.vim/grammarian/cautions/spell/en.utf-8.add.spl')
        exec 'mkspell /Users/damian/.vim/grammarian/cautions/spell/en.utf-8.add'
    endif
endfunction
silent call s:recompile_spelling_files()

" Switch on/off and between modes...
function! Grammarian_Toggle ()
    " Rotate matching type
    if s:grammarian_query_type == ''
        let s:grammarian_query_type = 'errors'
    elseif s:grammarian_query_type == 'errors'
        let s:grammarian_query_type = 'cautions'
    else
        let s:grammarian_query_type = ''
    endif

    " If no longer grammar-correcting...
    if empty(s:grammarian_query_type)
        " Reset key mappings to previous values...
        execute get(s:grammarian_restore, 'query',      '')
        execute get(s:grammarian_restore, 'correction', '')
        let s:grammarian_restore = {}

        " Clean up path for spelling
        let &runtimepath = substitute(&runtimepath, ',/Users/damian/.vim/grammarian/\w\+','','g')
        let &encoding = &encoding

        " Restore previous spelling appearance...
        highlight! link SpellBad GRAMMARIAN_OLD_SPELLBAD
        call matchdelete(s:GRAMMARIAN_ACTIVE_DISPLAY_ID)
        let s:GRAMMARIAN_ACTIVE_DISPLAY_ID = matchadd('GRAMMARIAN_ACTIVE_DISPLAY','x\@!x')
        call matchdelete(s:GRAMMARIAN_REPETITION_DISPLAY_ID)
        let s:GRAMMARIAN_REPETITION_DISPLAY_ID = matchadd('GRAMMARIAN_REPETITION_DISPLAY','x\@!x')

        " Turn off spelling...
        setlocal nospell

    " Otherwise, start grammar-correcting...
    else
        " Install query interface
        if empty(s:grammarian_restore)
            let s:grammarian_restore['query'] = Grammarian_Get_Mapping_For('n',"<TAB>")
            nnoremap <silent> <TAB>  :call Grammarian_Query()<CR>

            let s:grammarian_restore['correction'] = Grammarian_Get_Mapping_For('n',"<S-TAB>")
            nnoremap <silent> <S-TAB>  :call Grammarian_Correction()<CR>
        endif

        " Install error or caution data
        let &runtimepath = substitute(&runtimepath, ',/Users/damian/.vim/grammarian/\w\+','','g')
        let &runtimepath .= ',/Users/damian/.vim/grammarian/'.s:grammarian_query_type
        let &encoding = &encoding

        " Load explanations...
        exec 'source /Users/damian/.vim/grammarian/'.s:grammarian_query_type.'/data.vim'

        " Select highlighting...
        highlight! link GRAMMARIAN_OLD_SPELLBAD SpellBad
        if s:grammarian_query_type == 'errors'
            highlight! link SpellBad GRAMMARIAN_ERROR_DISPLAY

            call matchdelete(s:GRAMMARIAN_REPETITION_DISPLAY_ID)
            let s:GRAMMARIAN_REPETITION_DISPLAY_ID
            \ = matchadd('GRAMMARIAN_REPETITION_DISPLAY',s:REPEAT_MATCHER)
        else
            highlight! link SpellBad GRAMMARIAN_CAUTION_DISPLAY

            call matchdelete(s:GRAMMARIAN_REPETITION_DISPLAY_ID)
            let s:GRAMMARIAN_REPETITION_DISPLAY_ID = matchadd('GRAMMARIAN_REPETITION_DISPLAY','x\@!x')
        endif

        " Report toggle outcome...
        echohl GRAMMARIAN_INFORMATION_MSG
        echo 'Showing grammatical ' . s:grammarian_query_type
        echohl None

        setlocal spell
    endif
endfunction

" Find and report the next problem...
function! Grammarian_Query ()
    " Find a target...
    let target = ""
    let pos = getpos('.')
    let orig_pos = copy(pos)
    while 1
        " Is there something bad on the current line???
        let [target, type] = spellbadword()

        " Skip unimportant or retrograde matches...
        let new_pos = getpos('.')
        let explanation = get(g:grammarian_explanations,target,'')
        let nonsignificant = strlen(type)
        \               && (
        \                     type != 'bad'
        \                  || new_pos == s:grammarian_prev_match_pos
        \                  || empty(explanation)
        \                  )
        if nonsignificant
            let pos[2] += strlen(target)
            if pos[2] >= len(getline(pos[1]))
                let pos[1] += 1
                let pos[2] = 1
            endif
            call setpos('.', pos)
            redraw
            continue
        endif

        " Found a target (or none to find)...
        if !empty(target)
            let s:grammarian_prev_match_pos = new_pos
            break

        elseif pos[1] >= line('$')
            break

        " Keep looking...
        else
            let pos[1] += 1
            let pos[2] =  1
            call setpos('.', pos)
            redraw
        endif
    endwhile

    " Nothing more to report...
    if empty(target)
        echohl GRAMMARIAN_INFORMATION_MSG
        echo 'No further grammar warnings'
        echohl None
        call setpos('.', orig_pos)
        redraw
        return
    endif

    " Report problem...
    if s:grammarian_query_type == 'errors'
        echohl GRAMMARIAN_ERROR_DISPLAY
    else
        echohl GRAMMARIAN_CAUTION_DISPLAY
    endif
    echo get(g:grammarian_explanations,target,'Misspelling')
    echohl None

    " Make problem stand out...
    call matchdelete(s:GRAMMARIAN_ACTIVE_DISPLAY_ID)
    call matchadd('GRAMMARIAN_ACTIVE_DISPLAY', '\%#'.target, 10000, s:GRAMMARIAN_ACTIVE_DISPLAY_ID)

    redraw
endfunction

function! Grammarian_Correction ()
    " Do we have a target???
    let [target, type] = spellbadword()
    let explanation = get(g:grammarian_explanations, target, '')
    let suggestions = get(g:grammarian_suggestions,  target, [])
    if empty(target) || type != 'bad' || empty(explanation) || empty(suggestions)
        echohl GRAMMARIAN_ERROR_MSG
        echo "No suggestions"
        echohl None
        return
    endif

    " Auto-replace a sole suggestion...
    if len(suggestions) == 1
        let replacement = suggestions[0]

    " Otherwise prompt for a choice...
    else
        " Prepare for prompting...
        call inputsave()

        " Show options...
        let vertical_bar = repeat('_', winwidth(0)-2)
        echohl GRAMMARIAN_DECORATION
        echo vertical_bar
        echohl GRAMMARIAN_INFORMATION_MSG
        echo '"' . target . '" : ' . explanation
        echohl GRAMMARIAN_DECORATION
        echo vertical_bar
        let ord_a = char2nr('a')
        let n = ord_a
        for suggestion in suggestions
            if n == ord_a
                echohl GRAMMARIAN_SUGGESTION_DEFAULT_MSG
            else
                echohl GRAMMARIAN_SUGGESTION_MSG
            endif

            echo '    ' . nr2char(n) . '. ' . suggestion
            let n += 1
        endfor
        echohl GRAMMARIAN_DECORATION
        echo vertical_bar
        echohl None

        " Prompt...
        let selection = nr2char(getchar())
        call inputrestore()

        " Default selected...
        if selection == "\<CR>"
            let replacement = suggestions[0]

        " Explicit valid selection...
        elseif selection >= 'a' && selection < nr2char(n)
            let replacement = suggestions[char2nr(selection) - ord_a]

        " Anything else...
        else
            redraw!
            echohl GRAMMARIAN_INFORMATION_MSG
            echo "Cancelled"
            echohl None
            return
        endif
    endif

    " Apply replacement (without moving)...
    let pos = getpos('.')
    exec 's/\%#' . target . '/' . replacement . '/'
    call setpos('.', pos)

    " Make everything pretty again...
    redraw!

endfunction

function! Grammarian_Get_Mapping_For (mode, sequence)
    let sequence = eval('"' . substitute(a:sequence, '<', '\\<', 1) . '"')
    let desc = maparg(sequence, a:mode, 0, 1)
    if len(desc) > 0
        return (desc['noremap'] ? a:mode . 'noremap' : a:mode.'map')
        \    . ' '
        \    . (desc['silent'] ? '<silent>' : '')
        \    . (desc['expr']   ? '<expr>'   : '')
        \    . (desc['buffer'] ? '<buffer>' : '')
        \    . ' '
        \    . desc['lhs']
        \    . ' '
        \    . desc['rhs']
    else
        return a:mode . 'unmap ' . a:sequence
    endif
endfunction


" Toggle grammar checking...
nmap <silent> ;g  :call Grammarian_Toggle()<CR>


" Restore previous external compatibility options
let &cpo = s:save_cpo
