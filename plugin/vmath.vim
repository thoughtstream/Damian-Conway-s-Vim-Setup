" Vim global plugin for math on visual regions
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

"######################################################################
"##                                                                  ##
"##  To use:                                                         ##
"##                                                                  ##
"##     xmap <silent><expr>  ++  VMATH_YankAndAnalyse()              ##
"##     nmap <silent>        ++  vip++                               ##
"##                                                                  ##
"##  (or whatever keys you prefer to remap these actions to)         ##
"##                                                                  ##
"######################################################################


" If already loaded, we're done...
if exists("loaded_vmath")
    finish
endif
let loaded_vmath = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Grab visual selection and do simple math on it...
function! VMATH_YankAndAnalyse ()
    return "y:call VMATH_Analyse()\<CR>"
endfunction

" What to consider a number...
"let s:NUM_PAT  = '^[+-]\?\d\+\%([.]\d\+\)\?\([eE][+-]\?\d\+\)\?$'
let s:NUM_PAT  = '^[$€£¥]\?[+-]\?[$€£¥]\?\%(\d\{1,3}\%(,\d\{3}\)\+\|\d\+\)\%([.]\d\+\)\?\([eE][+-]\?\d\+\)\?$'

" What to consider a timing...
let s:TIME_PAT = '^\d\+\%([:]\d\+\)\+\%([.]\d\+\)\?$'

" How widely to space the report components...
let s:REPORT_GAP = 5  "spaces between components

" Do simple math on current yank buffer...
function! VMATH_Analyse ()
    "
    " Extract data from selection...
    let selection = getreg('')
    let raw_numbers = filter(split(selection), 'v:val =~ s:NUM_PAT')
    let raw_numbers = map(raw_numbers, 'substitute(v:val,"[,$€£¥]","","g")')
    let temporal = empty(raw_numbers)

    " If no numerical data, try time data...
    if temporal
        let raw_numbers
            \ = map( filter( split(selection),
            \                'v:val =~ s:TIME_PAT'
            \        ),
            \        's:str2sec(v:val)'
            \   )
    endif

    " Convert to calculable terms...
    let numbers = map(copy(raw_numbers), 'str2float(v:val)')

    " Results include a newline if original selection did...
    let newline = selection =~ "\n" ? "\n" : ""

    " Calculate various interesting metrics...
    let sum = s:tidy( eval( len(numbers) ? join( numbers, ' + ') : '0' ) )
    let avg = s:average(raw_numbers)
    let min = s:tidy( s:min(numbers) )
    let max = s:tidy( s:max(numbers) )

    " Convert temporals...
    if temporal
        let sum = s:tidystr( s:sec2str(sum) )
        let avg = s:tidystr( s:sec2str(avg) )
        let min = s:tidystr( s:sec2str(min) )
        let max = s:tidystr( s:sec2str(max) )
   endif

    " En-register metrics...
    call setreg('s', sum )
    call setreg('a', avg )
    call setreg('x', max )
    call setreg('n', min )
    call setreg('r', string(min) . ' to ' . string(max) )

    " Default paste buffer should depend on original contents (TODO)
    call setreg('', @s )

    " Report...
    let gap = repeat(" ", s:REPORT_GAP)
    redraw
    echo
    \    's̲um: ' . @s . gap
    \  . 'a̲vg: ' . @a . gap
    \  . 'min̲: ' . @n . gap
    \  . 'max̲: ' . @x . gap

endfunction

" Convert times to raw seconds...
function! s:str2sec (time)
    let components = split(a:time, ':')
    let multipliers = [60, 60*60, 60*60*24]
    let duration = str2float(remove(components, -1))
    while len(components)
        let duration += 1.0 * remove(multipliers,0) * remove(components, -1)
    endwhile
    return string(duration)
endfunction

" Convert raw seconds to times...
function! s:sec2str (duration)
    let fraction = str2float(a:duration)
    let duration = str2nr(a:duration)
    let fraction -= duration
    let fracstr = substitute(string(fraction), '^0', '', '')

    let sec = duration % 60
    let duration = duration / 60
    if !duration
        return printf('0:%02d', sec) . (fraction > 0 ? fracstr : '')
    endif

    let min = duration % 60
    let duration = duration / 60
    if !duration
        return printf('%d:%02d', min, sec) . (fraction > 0 ? fracstr : '')
    endif

    let hrs = duration % 24
    let duration = duration / 24
    if !duration
        return printf('%d:%02d:%02d', hrs, min, sec) . (fraction > 0 ? fracstr : '')
    endif

    return printf('%d:%02d:%02d:%02d', duration, hrs, min, sec) . (fraction > 0 ? fracstr : '')
endfunction

" Prettify numbers...
function! s:tidy (number)
    let tidied = printf('%g', a:number)
    return substitute(tidied, '[.]0\+$', '', '')
endfunction

function! s:tidystr (str)
    return substitute(a:str, '[.]0\+$', '', '')
endfunction

" Compute average with meaningful number of decimal places...
function! s:average (numbers)
    " Compute average...
    let summation = eval( len(a:numbers) ? join( a:numbers, ' + ') : '0' )
    let avg = 1.0 * summation / s:max([len(a:numbers), 1])

    " Determine significant figures...
    let min_decimals = 15
    for num in a:numbers
        let decimals = strlen(matchstr(num, '[.]\d\+$')) - 1
        if decimals < min_decimals
            let min_decimals = decimals
        endif
    endfor

    " Adjust answer...
    return min_decimals > 0 ? printf('%0.'.min_decimals.'f', avg)
    \                       : string(avg)
endfunction

" Reimplement these because the builtins don't handle floats (!!!)
function! s:max (numbers)
    if !len(a:numbers)
        return 0
    endif
    let numbers = copy(a:numbers)
    let maxnum = numbers[0]
    for nextnum in numbers[1:]
        if nextnum > maxnum
            let maxnum = nextnum
        endif
    endfor
    return maxnum
endfunction

function! s:min (numbers)
    if !len(a:numbers)
        return 0
    endif
    let numbers = copy(a:numbers)
    let minnum = numbers[0]
    for nextnum in numbers[1:]
        if nextnum < minnum
            let minnum = nextnum
        endif
    endfor
    return minnum
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
