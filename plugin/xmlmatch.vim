" Vim global plugin for autocompleting XML tags
" Last change:  Sat Apr 19 21:55:26 EST 2008
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_xmlmatch")
  finish
endif
let loaded_xmlmatch = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Allow users to prespecify their own mapping for the XML matching toggle
" For example, to name the matching toggle ';m' put the following in .vimrc:
"
"      map ;m <Plug>XMLMatchToggle
"
if !hasmapto('<Plug>XMLMatchToggle')
    " Otherwise, use \x (or whichever leader char they've selected)...
    map <unique> <Leader>x  <Plug>XMLMatchToggle
endif

" Within the current script map the XML matcher to call the Toggle function...
noremap <unique> <script> <Plug>XMLMatchToggle  <SID>Toggle
noremap <SID>Toggle  :call <SID>Toggle()<CR>


" Toggle remapping of > to insert a closing tag (but only after a tag)...
let s:matchtags = 0
function <SID>Toggle ()
    let s:matchtags = ! s:matchtags
    if s:matchtags
        inoremap <silent> > ><C-R>=<SID>InsertCloseTag()<CR>
        highlight default VerticalBar ctermbg=cyan
        let vbarpos = join(map(range(1,50),'"\\%".(&tabstop*v:val+1)."c"'),'\|')
        execute '2match VerticalBar /\%1c \| \zs\(' . vbarpos . '\) /'
        echo "<XML autoclose on>"
    else
        iunmap >
        2match none
        echo "<XML autoclose off>"
    endif
endfunction

" Pattern to recognize a (non-self closing) tag...
let s:OPENTAG_PATTERN = '<\(\h\w*\)\(''[^'']*''\|"[^"]*"\|[^>''"]\)*\/\@<!>'
"   Opening angle........: |^^^^^    ^^^^^^^^^^  ^^^^^^^  ^^^^^^^   ^^^^^^|
"     Capture______________|  :          |          :        |        :   |
"       Identifier............:          |          :        |        :   |
"         Double-quoted strings or_______|          :        |        :   |
"         Single-quoted strings or..................:        |        :   |
"         Unquoted anything else_____________________________|        :   |
"           No "self-closing" slash...................................:   |
"             Closing angle_______________________________________________|

" Logic to detect a preceding tag and close it appropriately...
function <SID>InsertCloseTag()
    " Ascertain current context...
    let currline = getline(".")

    " Pattern to recognize tag immediately before current cursor position...
    let opentag_before_cursor = s:OPENTAG_PATTERN . '\%' . col('.') . 'c'

    " Determine if start of tag is immediately before cursor position...
    let start_of_tag_pos = match(currline, opentag_before_cursor)

    " Insert closing tag if > is at the end of a tag...
    if start_of_tag_pos >= 0  
        " Extract tag name and build closing tag...
        let closetag = substitute(currline,
                       \          '.*' . opentag_before_cursor . '.*',
                       \          '</\1>',
                       \          "")

        " Create a whitespace indent to align opening and closing tags...
        let indent = printf( '%' . start_of_tag_pos . 's', '' )

        " Insert the closing tag, and an interim empty line...
        call append(".", indent . closetag)
        call append(".", indent)

        " Reset the cursor on the interim empty line, indented one tab...
        return "\<DOWN>\<TAB>"

    " Alternatively, if not at end of a tag, do nothing...
    else
        return ""
    endif
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
