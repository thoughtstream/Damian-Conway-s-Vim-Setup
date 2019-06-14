" Vim global plugin for folding text around search results
" Last change:  Wed Aug 10 10:06:31 BST 2011
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_foldsearch")
    finish
endif
let loaded_foldsearch = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Remember default behaviours...
let s:DEFFOLDMETHOD = &foldmethod
let s:DEFFOLDEXPR   = &foldexpr
let s:DEFFOLDTEXT   = &foldtext
let s:DEFFOLDLEVEL  = 1000

" This is what the options are changed to...
let s:FOLDEXPR = 'FS_FoldSearchLevel()'
let s:FOLDTEXT = {
    \'visible'   : "'___/ line ' . (v:foldend+1) . ' \\' . repeat('_',200) ",
    \'invisible' : "repeat(' ',200)",
    \'hud'       : "'123456789¹̥123456789²̥123456789³̥123456789⁴̥123456789"
    \            . "⁵̥123456789⁶̥123456789⁷̥123456789⁸̥123456789⁹̥123456789'"
    \            . " . repeat(' ',200)"
\}



" Turn the mechanism on and off...
function! FS_ToggleFoldAroundSearch (opts)
    if !exists('b:FS_DATA')
        let b:FS_DATA = { 'active' : 0, 'mode' : 'off' }
    endif

    " Decode args...
    let b:FS_DATA.context  = get(a:opts, 'context',  1)
    let b:FS_DATA.inverted = get(a:opts, 'inverted', 0)
    let newfoldmode        = get(a:opts, 'hud',      0) ? 'hud' : 'search'
    let &foldminlines      = 0

    " Showing folds (defaults to "yes")???
    let folds_visible = get(a:opts, 'folds', 'visible')

    " Remove any remanant autocommands...
    augroup FoldSearch
        autocmd!
    augroup END

    " Clear any folds (if we can)...
    silent! normal zE

    " Turn off, if it's on...
    if b:FS_DATA.active && newfoldmode == b:FS_DATA.mode
        " Restore the previous setup...
        let &foldmethod = get(b:FS_DATA, 'prevfoldmethod', s:DEFFOLDMETHOD)
        let &foldtext   = get(b:FS_DATA, 'prevfoldtext',   s:DEFFOLDTEXT)
        let &foldlevel  = get(b:FS_DATA, 'prevfoldlevel',  s:DEFFOLDLEVEL)
        let &foldexpr   = get(b:FS_DATA, 'prevfoldexpr',   s:DEFFOLDEXPR)

        " Then forget everything...
        unlet b:FS_DATA

        return '<C-L>'

    " Turn on, if it's off or a mode change...
    else
        " Turn on, and save old settings...
        if !b:FS_DATA.active
            let b:FS_DATA.prevfoldmethod = &foldmethod
            let b:FS_DATA.prevfoldexpr   = &foldexpr
            let b:FS_DATA.prevfoldtext   = &foldtext
            let b:FS_DATA.prevfoldlevel  = &foldlevel
            let b:FS_DATA.active         = 1
        endif

        " Set up ruler behaviour, if requested...
        if newfoldmode == 'hud'
            let b:FS_DATA.mode = 'hud'
            let b:FS_DATA.line = 0

            let &foldtext      = get(a:opts, 'folds', s:FOLDTEXT['hud'])
            let &foldmethod    = 'manual'
            let &foldlevel = 0

            " Recalculate folding for each new cursor position...
            augroup FoldSearch
                autocmd!
                autocmd CursorMoved * call FS_FoldRuler()
            augroup END

            " Show ruler initially...
            return 'zE:silent .'
            \      . ( line('.') <= b:FS_DATA.context ? '+' : '-' )
            \      . max([1, b:FS_DATA.context]) . "fold\<CR>"

        " Otherwise, set up search behaviour...
        else
            let b:FS_DATA.mode = 'search'

            let &foldtext   = get(s:FOLDTEXT, folds_visible, folds_visible)
            let &foldexpr   = s:FOLDEXPR
            let &foldmethod = 'expr'
            let &foldlevel  = 0

            " Recalculate folding for each new search...
            augroup FoldSearch
                autocmd!
                autocmd CursorMoved  *  let &foldexpr  = &foldexpr
                autocmd CursorMoved  *  let &foldlevel = 0
            augroup END

            return "\<C-L>"
        endif
    endif
endfunction

" Search for a particular target and turn search folding on (if not already on)...
function! FS_FoldAroundTarget (target, opts)
    let context       = get(a:opts, 'context', 1        )
    let folds_visible = get(a:opts, 'folds',   'visible')

    " If already in a foldsearch...
    if exists('b:FS_DATA')
        if b:FS_DATA.active
            " If already folding this pattern...
            if @/ == a:target
                " Toggle off...
                return ":nohlsearch\<CR>:exec 'normal ' . FS_ToggleFoldAroundSearch({'context':1})\<CR>"

            " Otherwise stay in foldsearch and switch to target...
            else
                let b:FS_DATA.context  = get(a:opts, 'context', 1)
                let b:FS_DATA.inverted = get(a:opts, 'inverted', 0)
                let &foldtext      = get(s:FOLDTEXT, folds_visible, folds_visible)
                let &foldminlines  = 1
                return '/' . a:target . "\<CR>"
            endif
        endif
    endif

    " If not already in a foldsearch, search for target then toggle on...
    return '/' . a:target . "\<CR>:exec 'normal ' . FS_ToggleFoldAroundSearch(".string(a:opts).")\<CR>"
endfunction

" Utility function implements folding expression...
function! FS_FoldSearchLevel ()
    " Allow one line of context before and after...
    let startline = v:lnum > b:FS_DATA.context ? v:lnum - b:FS_DATA.context : v:lnum
    let endline   = v:lnum < line('$') - b:FS_DATA.context ? v:lnum + b:FS_DATA.context : v:lnum
    let context = getline(startline, endline)

    " Simulate smartcase matching...
    let matchpattern = @/
    if &smartcase && matchpattern =~ '\u'
        let matchpattern = '\C'.matchpattern
    endif

    " Line is folded if surrounding context doesn't match last search pattern...
    let matched = match(context, matchpattern) == -1
    return get(b:FS_DATA,'inverted',0) ? !matched : matched

endfunction

function! FS_FoldRuler ()
    if exists('b:FS_DATA') && b:FS_DATA.line != line('.')
        let b:FS_DATA.line = line('.')
        normal zE
        silent exec '.'
        \          . ( b:FS_DATA.line <= b:FS_DATA.context ? '+' : '-' )
        \          . max([1, b:FS_DATA.context]) . 'fold'
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
