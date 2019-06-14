" Vim global plugin for XXXX
"
" Last change:  2018-06-03T03:06:48+1000
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_warmmargin")
    finish
endif
let loaded_warmmargin = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"====[ Show when lines extend past column 80 ]=================================>!<============

" Config...
let s:defaultTemps        = [226, 220, 214, 208, 202, 196]
let s:defaultBgTemps      = []
let s:defaultSingleTemp   = 208
let s:defaultSingleBgTemp = 'Black'
let s:defaultCol          = 80
let s:highlights          = []
let s:ACTIVE_SINGLE       = 1
let s:ACTIVE_ON           = 2
let s:active              = s:ACTIVE_SINGLE

" Control behaviours with this function...
function! WarmMargin (mode)
    " Clear existing highlights...
    for matchID in s:highlights
        try
            call matchdelete(matchID)
        catch /./
        endtry
    endfor
    let s:highlights = []

    " What are we doing this time...
    if a:mode == 'never'
        let b:WarmMarginNever = 1
    endif
    if get(b:, 'WarmMarginNever', 0)
        return
    endif

    if a:mode == 'single'
        let s:active = s:ACTIVE_SINGLE
    elseif a:mode == 'full'
        let s:active = s:ACTIVE_ON
    elseif a:mode == 'toggle'
        let s:active = -s:active
    elseif a:mode == 'on'
        let s:active =  abs(s:active)
    else
        let s:active = -abs(s:active)
    endif

    " Set up highlights and matching rules...
    if s:active == s:ACTIVE_SINGLE
        " Get config...
        let heat0   = get(g:, 'WarmMarginSingleTemp',   s:defaultSingleTemp)
        let heatbg0 = get(g:, 'WarmMarginSingleBgTemp', s:defaultSingleBgTemp)
        let margin  = get(g:, 'WarmMarginSingleCol',    s:defaultCol)

        " Install highlight and match rule...
        exec 'highlight WarmMargin_0 ctermfg=' . heat0 . ' ctermbg=' . heatbg0
        call add(s:highlights, matchadd('WarmMargin_0', '\%' . (margin+1) . 'v\s*\zs\S', 100) )

    elseif s:active == s:ACTIVE_ON
        " Get config...
        let heat   = reverse( copy(get(g:, 'WarmMarginTemps',   s:defaultTemps   )))
        let heatbg = reverse( copy(get(g:, 'WarmMarginBgTemps', s:defaultBgTemps )))
        let margin =               get(g:, 'WarmMarginCol',     s:defaultCol)

        " Install highlights and match rules...
        for delta in range( max( [len(heat), len(heatbg)] ) )

            exec 'highlight WarmMargin_'. delta
            \           . ' ctermfg=' . get(heat,   delta, get(heat,   0, 'Red'  ))
            \           . ' ctermbg=' . get(heatbg, delta, get(heatbg, 0, 'Black'))

            call add(s:highlights,
            \        matchadd(
            \            'WarmMargin_' . delta,
            \            '\%' . (delta ? margin-delta+1 : '>'.margin) . 'v\s*\zs\S',
            \            100-delta
            \        )
            \    )
        endfor
    endif

endfunction

augroup WarmMargin
    autocmd!
    autocmd  BufEnter  *  WarmMargin on
augroup END

command -nargs=1 -complete=customlist,WarmMarginComplete  WarmMargin   :call WarmMargin(<q-args>)

function! WarmMarginComplete (lead, cmd, at)
    return filter(['on','off','toggle','never','single','full'], {idx, val -> val =~ '^'.a:lead})
endfunction

" Start in 'single' mode
: WarmMargin('single')


" Restore previous external compatibility options
let &cpo = s:save_cpo

