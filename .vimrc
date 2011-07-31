"====[ Toggle visibility of naughty characters ]============

set lcs=tab:\ »,trail:·,nbsp:~

"=====[ Miscellaneous configuration ]====================

set comments-=s1:/*,mb:*,ex:*/      "Don't recognize C comments
set comments-=:XCOMM                "Don't recognize lmake comments
set comments-=:%                    "Don't recognize PostScript comments
set comments+=fb:*                  "Star-space is a bullet
set comments+=fb:-                  "Dash-space is a bullets
"set formatoptions+=ac
"set formatoptions=

set wrapmargin=78
set autoindent                              "Retain indentation on next line
set smartindent                             "Turn on autoindenting of blocks
set cinwords = ""                           "But not for C-like keywords
inoremap # X<C-H>#|                         "And no magic outdent for comments
nnoremap <silent> >> :call ShiftLine()<CR>| "And no shift magic on comments

function! ShiftLine()
    set nosmartindent
    normal! >>
    set smartindent
endfunction


"=====[ Make Visual modes work better ]==================

" Visual Block mode is far more useful to me that Visual mode...
nnoremap v <C-V>
nnoremap <C-V> v

" Make BS/DEL work as expected in visual mode (i.e. make it delete)
vmap <BS> x

" Make vaa select the entire file via visual mode
vmap aa VGo1G

"Square up visual selections
set virtualedit=block


"=====[ Demo vim commands ]==============================

highlight WHITE_ON_BLACK ctermfg=white

function! MakeDemoCommand ()
    map <silent> ;; :call DemoCommand()<CR>
    vmap <silent> ;; :<C-U>call DemoCommand(1)<CR>

    function! DemoCommand (...)
        let orig_buffer = getline('w0','w$')
        let orig_match  = matcharg(1)
        if a:0
            let @@ = join(getline("'<","'>"), "\n")
        else
            silent normal vipy
        endif
        match WHITE_ON_RED /\%V/
        redraw
        sleep 500m
        execute substitute(@@, '\n\s*\\', ' ', 'g')
        if getline('w0','w$') != orig_buffer
            redraw
            sleep 1000m
        endif
        if strlen(orig_match[0])
            execute 'match ' . orig_match[0] . ' /' . orig_match[1] . '/'
        else
            call BadRefs()
        endif
    endfunction
endfunction

call MakeDemoCommand()


"=====[ Syntax highlighting ]==============================

nmap <silent> ;y : if exists("syntax_on") <BAR>
                 \    syntax off <BAR>
                 \ else <BAR>
                 \    syntax enable <BAR>
                 \ endif<CR>


"=====[ Permanent features ]==================================

set title           "Show filename in titlebar of window
set titleold=

set nomore          "Don't page long listings

set autowrite       "Save buffer automatically when changing files
set autoread        "Always reload buffer when external changes detected

set viminfo=h,'50,<10000,s1000,/1000,:100

set backspace=indent,eol,start      "BS past autoindents, line boundaries,
                                    "     and even the start of insertion

set matchpairs+=<:>,«:»             "Match angle brackets too

set background=dark                 "When guessing, guess bg is dark


set fileformats=unix,mac,dos        "Handle Mac and DOS line-endings
                                    "but prefer Unix endings


set wildmode=list:longest,full      "Show list of completions
                                    "  and complete as much as possible,
                                    "  then iterate full completions

set noshowmode                      "Suppress mode change messages


set updatecount=10                  "Save buffer every 10 chars typed


set textwidth=78                    "Wrap at column 78

" Keycodes and maps timeout in 3/10 sec...
set timeout timeoutlen=300 ttimeoutlen=300

set thesaurus+=~/Documents/thesaurus    "Add thesaurus file for ^X^T
set dictionary+=~/Documents/dictionary  "Add dictionary file for ^X^K

"Adjust keyord characters for Perlish identifiers...
set iskeyword+=$
set iskeyword+=%
set iskeyword+=@
set iskeyword-=,

set incsearch                       "Lookahead as search pattern specified
set ignorecase                      "Ignore case in all searches...
set smartcase                       "...unless uppercase letters used
set hlsearch                        "Highlight all search matches

"Switch off highlighting till next search and clear messages...
nmap <silent> <BS> :nohlsearch <BAR> set nocursorcolumn<CR>


set scrolloff=2                     "Scroll when 2 lines from top/bottom

set ruler                           "Show cursor location info on status line


" Use space to jump down a page (like browsers do)...
noremap <Space> <PageDown>


" Edit a file...
map e :n 


" Forward/back one file...
map <DOWN> :next<CR>0
map <UP>   :prev<CR>0


" Swap back to alternate file...
map g  :w<CR>:e #<CR>


" Format file with perltidy...
map ;t 1G!Gperltidy<CR>


" Execute Perl file (output to pager)...
map E :!mperl -w %<CR>

" Execute Perl file...
map W :!clear;echo;echo;perl %;echo;echo;echo<CR>

" Debug Perl file...
map Q :!perl -d %<CR>




" Add *** as **/* on command-line...
cmap *** **/*


" New command to empty a file
nmap XX 1GdG


"=====[ Show help files in a new tab, plus shortcut for helpg ]==============

augroup HelpInTabs
    au!
    au BufEnter  *.txt   call HelpInNewTab()
augroup END

function! HelpInNewTab ()
    if &buftype == 'help'
        normal T
    endif
endfunction

function! CommandExpandAtCol1 (from, to)
    if strlen(getcmdline()) || getcmdtype() != ':'
        return a:from
    else 
        return a:to
    endif
endfunction

cmap <expr> hh CommandExpandAtCol1('hh','helpg ')

"=====[ Cut and paste from MacOSX clipboard ]====================

nmap <silent> <C-P> :set paste<CR>
                   \!!pbtranspaste<CR>
                   \:set nopaste<CR>
                   \:set fileformat=unix<CR>

vmap <silent> <C-P> x:call TransPaste(visualmode())<CR>

function! TransPaste(type)
    let reg_save = @@

    let clipboard = system("pbtranspaste")

    call setreg('@', clipboard, a:type)

    silent exe "normal! P"

    let @@ = reg_save
endfunction


nmap <silent> <C-C> :w !pbtranscopy<CR><CR>
vmap <silent> <C-C> :<C-U>call TransCopy(visualmode(), 1)<CR>

function! TransCopy(type, ...)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == 'line'
    silent exe "normal! '[V']y"
    elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
    else
    silent exe "normal! `[v`]y"
    endif

    call system("pbtranscopy", @@)

    let &selection = sel_save
    let @@ = reg_save
endfunction



" Insert cut marks...
map -- A<CR><CR><CR><ESC>k6i-----cut-----<ESC><CR>


" Indent/outdent current block...
map %% $>i}``
map $$ $<i}``


"=====[ Convert file to different tabspacings ]=====================

function! NewTabSpacing (newtabsize)
    let was_expanded = &expandtab
    normal TT
    execute "set ts=" . a:newtabsize
    execute "set sw=" . a:newtabsize
    execute "map          F !Gformat -T" . a:newtabsize . " -"
    execute "map <silent> f !Gformat -T" . a:newtabsize . "<CR>"
    if was_expanded
        normal TS
    endif
endfunction

map <silent> T@ :call NewTabSpacing(2)<CR>
map <silent> T# :call NewTabSpacing(3)<CR>
map <silent> T$ :call NewTabSpacing(4)<CR>
map <silent> T% :call NewTabSpacing(5)<CR>
map <silent> T^ :call NewTabSpacing(6)<CR>
map <silent> T& :call NewTabSpacing(7)<CR>
map <silent> T* :call NewTabSpacing(8)<CR>
map <silent> T( :call NewTabSpacing(9)<CR>

" Convert to/from spaces/tabs...
map <silent> TS :set   expandtab<CR>:%retab!<CR>
map <silent> TT :set noexpandtab<CR>:%retab!<CR>


"=====[ Correct common mistypings in-the-fly ]=======================

iab    retrun  return
iab     pritn  print
iab       teh  the
iab      liek  like
iab  liekwise  likewise
iab      Pelr  Perl
iab      pelr  perl
iab        ;t  't
iab      moer  more
iab  previosu  previous


"=====[ Programming support ]===================================

" Insert shebang lines...
iab hbc #! /bin/csh 
iab hbs #! /bin/sh 
iab hb8 #! /usr/bin/perl -w
iab hbp #! /opt/local/bin/perl5.10.0<CR>use 5.010;<CR>use warnings;
iab hbr #! /Users/damian/bin/rakudo<CR>use v6;

" Insert common Perl code structures...
iab udd use Data::Dumper 'Dumper';<CR>warn Dumper [];<ESC>hi
iab ubm use Benchmark qw( cmpthese );<CR><CR>cmpthese -10, {<CR>};<ESC>O	
iab usc use Smart::Comments;<CR>###
iab uts use Test::Simple 'no_plan';
iab utm use Test::More 'no_plan';
iab dbs $DB::single = 1;<ESC>

" Add new highlight combinations...
highlight YELLOW_ON_BLACK ctermfg=yellow ctermbg=black   
highlight WHITE_ON_RED    ctermfg=white  ctermbg=red   

" Track "faux" references...
function! BadRefs ()
    match WHITE_ON_RED /_ref[ ]*[[{(]\|_ref[ ]*-[^>]/
endfunction
call BadRefs()


"=====[ Auto-setup for Perl scripts and modules ]===========

augroup Perl_Setup
au!
au BufNewFile *.p[lm] 0r !file_template <afile>
au BufNewFile *.p[lm] 1/^[ \t]*[#].*implementation[ \t]\+here/
augroup END

"=====[ Proper syntax highlighting for Rakudo files ]===========

autocmd BufNewFile,BufRead  *   :call CheckForRakudo()

function! CheckForRakudo ()
    if getline(1) =~ 'rakudo'
        setfiletype perl6
    endif
endfunction

"=====[ Tab handling ]======================================

set tabstop=4     "Indentation levels every four columns
set expandtab     "Convert all tabs that are typed into spaces
set shiftwidth=4  "Indent/outdent by four columns
set shiftround    "Always indent/outdent to nearest tabstop
set smarttab      "Use shiftwidths at left margin, tabstops everywhere else

" Use the smartcom plugin to remap <TAB> and <S-TAB>
runtime plugin/smartcom.vim

" Add extra completions for the smartcom.vim tab completion plugin...

call SmartcomAdd( '<<',   "",    '>>',                            1 )
call SmartcomAdd( '<<',   '>>',  "\<CR>\<ESC>O\<TAB>"               )
call SmartcomAdd( '{{',   "",    '}}',                            1 )
call SmartcomAdd( '{{',   '}}',  ""                                 )
call SmartcomAdd( 'qr{',  "",    '}xms',                          1 )
call SmartcomAdd( 'qr{',  '}xms',"\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",  )
call SmartcomAdd( 'm{',  "",    '}xms',                          1 )
call SmartcomAdd( 'm{',  '}xms',"\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",  )
call SmartcomAdd( 's{',  "",    '}{}xms',                          1 )
call SmartcomAdd( 's{',  '}{}xms',"\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",  )
call SmartcomAdd( '\*\*', "",    '**',                            1 )
call SmartcomAdd( '\*\*', '\*\*', ""                                )
call SmartcomAdd( '«',    "",    '»',                             1 )
call SmartcomAdd( '«',    '»',   "\<CR>\<ESC>O\<TAB>"               )

call SmartcomAdd( 'function!',  "",  "\<CR>endfunction", 1 )

call SmartcomAddAction( '^\s*use\s\+\k\+', "",
\                       'set complete=k~/.vim/perlmodules|set iskeyword+=:'
\)


" Make the completion popup look menu-ish on a Mac...
highlight  Pmenu        ctermbg=white   ctermfg=black 
highlight  PmenuSel     ctermbg=blue    ctermfg=white   cterm=bold
highlight  PmenuSbar    ctermbg=grey    ctermfg=grey
highlight  PmenuThumb   ctermbg=blue    ctermfg=blue


"=====[ Grammar checking ]========================================

" let g:check_grammar = 0

highlight BOLD  term=bold cterm=bold gui=bold

let s:problem_words = [
\       "it's",  "its",
\       "were",  "we're",   "where", 
\       "their", "they're", "there", 
\       "your",  "you're",
\ ]

let s:words_matcher
\   = 'match BOLD /\c\<\(' . join(s:problem_words, '\|') . '\)\>/' 

function! CheckGrammar () 
    let w:check_grammar = exists('w:check_grammar') ? !w:check_grammar : 1
    if !w:check_grammar
        call BadRefs()
    else
        exec s:words_matcher
    endif
    echo ""
endfunction

" Toggle grammar checking...
map <silent> ;g :call CheckGrammar()<CR>


"=====[ Add or subtract comments ]===============================

function! ToggleComment () 
    let currline = getline(".")
    if currline =~ '^#'
        s/^#//
    else "if currline =~ '\S'
        s/^/#/
    endif
endfunction

function! ToggleBlock () range
    let currline = getline(a:firstline)
    if currline =~ '^#'
        execute ":" . a:firstline . "," . a:lastline . "s/^#//"
    else "if currline =~ '\S'
        execute ":" . a:firstline . "," . a:lastline . "s/^/#/"
    endif
endfunction

 map <silent> # :call ToggleComment()<CR>j0
vmap <silent> # :call ToggleBlock()<CR>


"=====[ Highlight cursor column on request ]===================

highlight CursorColumn term=bold ctermfg=black ctermbg=green cterm=bold
highlight CursorLine   term=bold ctermfg=white ctermbg=red   cterm=bold
map <silent> ;c :set cursorcolumn!<CR>
map <silent> ;r :set cursorline!<CR>


"=====[ Highlight spelling errors on request ]===================

set spelllang=en_au
map <silent> ;s :setlocal invspell<CR>


"======[ Create a toggle for the XML completion plugin ]=======

map ;x <Plug>XMLMatchToggle


"======[ Order-preserving uniqueness ]=========================

function! TrimWS (str)
    let trimmed = substitute(a:str, '^\s\+\|\s\+$', '', 'g')
    return substitute(trimmed, '\s\+', ' ', 'g')
endfunction

function! Uniq (...) range
    " Ignore whitespace differences, if asked to...
    let ignore_ws_diffs = len(a:000)

    " Nothing unique seen yet...
    let seen = {}
    let uniq_lines = []

    " Walk through the lines, remembering only the hitherto unseen ones...
    for line in getline(a:firstline, a:lastline) 
        let normalized_line = '>' . (ignore_ws_diffs ? TrimWS(line) : line)
        if !get(seen,normalized_line)
            call add(uniq_lines, line)
            let seen[normalized_line] = 1
        endif
    endfor

    " Replace the range of original lines with just the unique lines...
    exec a:firstline . ',' . a:lastline . 'delete'
    call append(a:firstline-1, uniq_lines)
endfunction

vmap  u :call Uniq()<CR>
vmap  U :call Uniq(1)<CR>


"======[ Magically build interim directories if necessary ]===================

function! AskQuit (msg, options, quit_option)
    if confirm(a:msg, a:options) == a:quit_option
        exit
    endif
endfunction

function! EnsureDirExists ()
    let required_dir = expand("%:h")
    if !isdirectory(required_dir)
        call AskQuit("Parent directory '" . required_dir . "' doesn't exist.",
             \       "&Create it\nor &Quit?", 2)     

        try
            call mkdir( required_dir, 'p' )
        catch
            call AskQuit("Can't create '" . required_dir . "'",
            \            "&Quit\nor &Continue anyway?", 1)
        endtry
    endif
endfunction

augroup AutoMkdir
    autocmd!
    autocmd  BufNewFile  *  :call EnsureDirExists()
augroup END


"=====[ There can be only one (...Vim session per file) ]=====================

augroup NoSimultaneousEdits
    au!
    au SwapExists * let v:swapchoice = 'o'
    au SwapExists * echohl ErrorMsg
    au SwapExists * echo 'Duplicate edit session (readonly)'
    au SwapExists * echohl None
    au SwapExists * sleep 2
augroup END

