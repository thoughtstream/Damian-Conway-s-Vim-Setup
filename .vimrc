"====[ Edit and auto-update this config file ]==========

augroup VimReload
    au!
    au BufWritePost $MYVIMRC source $MYVIMRC
augroup END

nmap <silent>  ;v  :next $MYVIMRC<CR>


"====[ Work out what kind of file this is ]========

filetype plugin on


"====[ Go back to alternate file (but retain other g<whatever> mappings)]====

map g  :w<CR>:e #<CR>

function! s:conditional_nnoremap ( name )
    if maparg(a:name, 'n') == ""
        execute 'nnoremap  <unique> ' . a:name . ' ' . a:name
    endif
endfunction
call s:conditional_nnoremap( 'g~' )
call s:conditional_nnoremap( 'g~~' )
call s:conditional_nnoremap( 'g~g~' )
call s:conditional_nnoremap( 'g#' )
call s:conditional_nnoremap( 'g$' )
call s:conditional_nnoremap( 'g&' )
call s:conditional_nnoremap( "g'" )
call s:conditional_nnoremap( 'g*' )
call s:conditional_nnoremap( 'g0' )
call s:conditional_nnoremap( 'g8' )
call s:conditional_nnoremap( 'g<' )
call s:conditional_nnoremap( 'g<C-G>' )
call s:conditional_nnoremap( 'g<C-H>' )
call s:conditional_nnoremap( 'g<C-]>' )
call s:conditional_nnoremap( 'g<Down>' )
call s:conditional_nnoremap( 'g<End>' )
call s:conditional_nnoremap( 'g<Home>' )
call s:conditional_nnoremap( 'g<LeftMouse>' )
call s:conditional_nnoremap( 'g<MiddleMouse>' )
call s:conditional_nnoremap( 'g<RightMouse>' )
call s:conditional_nnoremap( 'g<Up>' )
call s:conditional_nnoremap( 'g?' )
call s:conditional_nnoremap( 'g??' )
call s:conditional_nnoremap( 'g?g?' )
call s:conditional_nnoremap( 'g@' )
call s:conditional_nnoremap( 'gD' )
call s:conditional_nnoremap( 'gE' )
call s:conditional_nnoremap( 'gF' )
call s:conditional_nnoremap( 'gH' )
call s:conditional_nnoremap( 'gI' )
call s:conditional_nnoremap( 'gJ' )
call s:conditional_nnoremap( 'gP' )
call s:conditional_nnoremap( 'gR' )
call s:conditional_nnoremap( 'gU' )
call s:conditional_nnoremap( 'gUU' )
call s:conditional_nnoremap( 'gUgU' )
call s:conditional_nnoremap( 'gV' )
call s:conditional_nnoremap( 'g]' )
call s:conditional_nnoremap( 'g^' )
call s:conditional_nnoremap( 'g`' )
call s:conditional_nnoremap( 'ga' )
call s:conditional_nnoremap( 'gd' )
call s:conditional_nnoremap( 'ge' )
call s:conditional_nnoremap( 'gf' )
call s:conditional_nnoremap( 'gg' )
call s:conditional_nnoremap( 'gh' )
call s:conditional_nnoremap( 'gi' )
call s:conditional_nnoremap( 'gj' )
call s:conditional_nnoremap( 'gk' )
call s:conditional_nnoremap( 'gm' )
call s:conditional_nnoremap( 'go' )
call s:conditional_nnoremap( 'gp' )
call s:conditional_nnoremap( 'gq' )
call s:conditional_nnoremap( 'gr' )
call s:conditional_nnoremap( 'gs' )
call s:conditional_nnoremap( 'gu' )
call s:conditional_nnoremap( 'gugu' )
call s:conditional_nnoremap( 'guu' )
call s:conditional_nnoremap( 'gv' )
call s:conditional_nnoremap( 'gw' )
"call s:conditional_nnoremap( 'gx' )


"====[ Goto last location in non-empty files ]=======

au BufReadPost *  if line("'\"") > 1 && line("'\"") <= line("$")
              \|     exe "normal! g`\""
              \|  endif


"====[ I'm sick of typing :%s/.../.../g ]=======

nmap S  :%s//g<LEFT><LEFT>
vmap S  :s//g<LEFT><LEFT>


"====[ Toggle visibility of naughty characters ]============

" Make naughty characters visible...
" (uBB is right double angle, uB7 id middle dot)
exec "set lcs=tab:\uBB\uBB,trail:\uB7,nbsp:~"

augroup VisibleNaughtiness
    au!
    au BufEnter  *       set list
    au BufEnter  *.txt   set nolist
    au BufEnter  *.vp*   set nolist
    au BufEnter  *       if !&modifiable
    au BufEnter  *           set nolist
    au BufEnter  *       endif
augroup END


"====[ Set up smarter search behaviour ]=======================
set incsearch                       "Lookahead as search pattern specified
set ignorecase                      "Ignore case in all searches...
set smartcase                       "...unless uppercase letters used
set hlsearch                        "Highlight all search matches

"Delete in normal mode to switch off highlighting till next search and clear messages...
nmap <silent> <BS> :nohlsearch <BAR> call Toggle_CursorColumn('off')<CR>

"Double-delete to remove search highlighting *and* trailing whitespace...
nmap <silent> <BS><BS>  mz:%s/\s\+$//g<CR>`z:nohlsearch<CR>


"====[ Handle encoding issues ]============

set encoding=latin1

nmap <silent> U :call ToggleUTF8()<CR>

function! ToggleUTF8 ()
    if &fileencoding =~ 'utf-\?8'
        set fileencoding=latin1
    else
        set fileencoding=utf8
    endif
    echo '[' . &fileencoding . ']'
endfunction



"====[ Set background hint (if possible) ]=============

if $VIMBACKGROUND != ""
    exec 'set background=' . $VIMBACKGROUND
else
    set background=dark
endif


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


"=====[ There can be only one (one Vim session per file) ]=====================

augroup NoSimultaneousEdits
    au!
    au SwapExists * let v:swapchoice = 'o'
    au SwapExists * echohl ErrorMsg
    au SwapExists * echo 'Duplicate edit session (readonly)'
    au SwapExists * echohl None
    au SwapExists * sleep 2
augroup END


"=====[ Enable smartwrapping ]==================================

" No smartwrapping in any of these files...
"let g:SW_IGNORE_FILES = '.vimrc,*.vim,*.pl,*.pm,**/bin/**'

" set comments-=s1:/*,mb:*,ex:*/      "Don't recognize C comments
" set comments-=:XCOMM                "Don't recognize lmake comments
" set comments-=:%                    "Don't recognize PostScript comments
" set comments-=:#                    "Don't recognize Perl/shell comments
" set comments+=fb:*                  "Star-space is a bullet
" set comments+=fb:-                  "Dash-space is a bullets

set formatoptions-=cro

set wrapmargin=2                            "Wrap 2 characters from the edge of the window
set autoindent                              "Retain indentation on next line
set smartindent                             "Turn on autoindenting of blocks
"set cinwords = ""                           "But not for C-like keywords
inoremap # X<C-H>#|                         "And no magic outdent for comments
nnoremap <silent> >> :call ShiftLine()<CR>| "And no shift magic on comments

function! ShiftLine()
    set nosmartindent
    normal! >>
    set smartindent
endfunction


"=====[ Handle Perl include files better ]==================================

" For Perl syntax...
set include=^\\s*use\\s\\+\\zs\\k\\+\\ze
set includeexpr=substitute(v:fname,'::','/','g')
set suffixesadd=.pm
execute 'set path+=' . substitute($PERL5LIB, ':', ',', 'g')


"====[ I hate modelines ]===================

set modelines=0


"=====[ Make Visual modes work better ]==================

" Visual Block mode is far more useful that Visual mode (so swap the commands)...
nnoremap v <C-V>
nnoremap <C-V> v

vnoremap v <C-V>
vnoremap <C-V> v

" Make BS/DEL work as expected in visual modes (i.e. delete elected)...
vmap <BS> x

" Make vaa select the entire file...
vmap aa VGo1G

"Square up visual selections...
set virtualedit=block

" When shifting, retain selection over multiple shifts...
vmap <expr> > KeepVisualSelection(">")
vmap <expr> < KeepVisualSelection("<")

function! KeepVisualSelection(cmd)
    if mode() ==# "V"
        return a:cmd . "gv"
    else
        return a:cmd
    endif
endfunction

" Temporarily add a column indicator when inserting or appending in visual mode...
" (Should use <C-O> instead, but it doesn't seem to work)
vnoremap <silent>  I  I<C-R>=TemporaryColumnMarkerOn()<CR>
vnoremap <silent>  A  A<C-R>=TemporaryColumnMarkerOn()<CR>

function! TemporaryColumnMarkerOn ()
    let g:prev_cursorcolumn_state = g:cursorcolumn_visible ? 'on' : 'off'
    call Toggle_CursorColumn('on')
    inoremap <silent>  <ESC>  <ESC>:call TemporaryColumnMarkerOff(g:prev_cursorcolumn_state)<CR>
    return ""
endfunction

function! TemporaryColumnMarkerOff (newstate)
    call Toggle_CursorColumn(a:newstate)
    iunmap <ESC>
endfunction


"=====[ Demo vim commands ]==============================

highlight WHITE_ON_BLACK ctermfg=white

map <silent> ;; :call DemoCommand()<CR>
vmap <silent> ;; :<C-U>call DemoCommand(1)<CR>

function! DemoCommand (...)
    " Remember how everything was before we did this...
    let orig_buffer = getline('w0','w$')
    let orig_match  = matcharg(1)

    " Select either the visual region, or the current paragraph...
    if a:0
        let @@ = join(getline("'<","'>"), "\n")
    else
        silent normal vipy
    endif

    " Highlight the selection in red to give feedback...
    let matchid = matchadd('WHITE_ON_RED','\%V')
    redraw
    sleep 500m

    " Remove continuations and convert shell commands, then execute...
    let command = @@
    let command = substitute(command, '^\s*".\{-}\n', '',     'g')
    let command = substitute(command, '\n\s*\\',      ' ',    'g')
    let command = substitute(command, '^\s*>\s',      ':! ',  '' )
    execute command

    " If the buffer changed, hold the highlighting an extra second...
    if getline('w0','w$') != orig_buffer
        redraw
        sleep 1000m
    endif

    " Remove the highlighting...
    call matchdelete(matchid)
endfunction


"=====[ Toggle syntax highlighting ]==============================

nmap <silent> ;y : if exists("syntax_on") <BAR>
                 \    syntax off <BAR>
                 \ else <BAR>
                 \    syntax enable <BAR>
                 \ endif<CR>


"=====[ Configure % key ]==============================

" Match angle brackets
set matchpairs+=<:>,«:»

let TO = ':'
let OR = ','

" Match double-angles, XML tags and Perl keywords
let b:match_words =
\
\                          '<<' .TO. '>>'
\
\.OR.     '<\@<=\(\w\+\)[^>]*>' .TO. '<\@<=/\1>'
\
\.OR. '\<if\>' .TO. '\<elsif\>' .TO. '\<else\>'

" Engage debugging mode to overcome bug in matchpairs matching...
let b:match_debug = 1


"=====[ Miscellaneous features (mainly options) ]=====================

set title           "Show filename in titlebar of window
set titleold=

set nomore          "Don't page long listings

set autowrite       "Save buffer automatically when changing files
set autoread        "Always reload buffer when external changes detected

"           +--Disable hlsearch while loading viminfo
"           | +--Remember marks for last 50 files
"           | |   +--Remember up to 1000 lines in each register
"           | |   |      +--Remember up to 1MB in each register
"           | |   |      |     +--Remember last 1000 search patterns
"           | |   |      |     |     +---Remember last 100 commands
"           | |   |      |     |     |
"           v v   v      v     v     v
set viminfo=h,'50,<10000,s1000,/1000,:100

set backspace=indent,eol,start      "BS past autoindents, line boundaries,
                                    "     and even the start of insertion

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

"Adjust keyword characters for Perlish identifiers...
set iskeyword+=$
set iskeyword+=%
set iskeyword+=@
set iskeyword-=,


set scrolloff=2                     "Scroll when 2 lines from top/bottom

set ruler                           "Show cursor location info on status line


"=====[ Remap various keys to something more useful ]========================

" Use space to jump down a page (like browsers do)...
nnoremap <Space> <PageDown>

" Back up the current file
nmap BB :!bak %<CR><CR>:echomsg "Backed up" expand('%')<CR>

" Edit a file...
nmap e :n<SPACE>

" Forward/back one file...
nmap <DOWN> :next<CR>0
nmap <UP>   :prev<CR>0

" Format file with perltidy...
nmap ;t 1G!Gperltidy<CR>

" Format file with autoformat (capitalize to specify options)...
nmap          F !Gformat -T4 -
nmap <silent> f !Gformat -T4<CR>
vmap          F :!format -T4 -all -
vmap <silent> f :!format -T4 -all<CR>


" Execute Perl file (output to pager)...
nmap E :!hashbang -m %<CR>


" Execute Perl file (report compilation time)...
nmap W :!clear;echo;echo;hashbang %;echo;echo;echo<CR>


" Debug Perl file...
nmap Q :!hashbang -d %<CR>


" Execute file polymorphically...
nmap ,, :w<CR>:!clear;echo;echo;run %<CR>
nmap ,,, :w<CR>:!clear;echo;echo;run -d %<CR>


" Run perldoc...
nmap <expr> ?? CallPerldoc()
set keywordprg=pd

function! CallPerldoc ()
    let target = matchstr(expand('<cfile>'), '\w\+\(::\w\+\)*')
    set wildmode=list:full
    return ":Perldoc "
endfunction

command! -nargs=1 -complete=customlist,CompletePerlModuleNames Perldoc  call Perldoc_impl(<q-args>)

function! Perldoc_impl (args)
    set wildmode=list:longest,full
    exec '!pd ' . a:args
endfunction
let s:module_files = readfile($HOME.'/.vim/perlmodules')
function! CompletePerlModuleNames(prefix, cmdline, curpos)
    let cfile = expand('<cfile>')
    let prefix = a:prefix
    if prefix == cfile
        let prefix = ""
    endif
    if empty(prefix) && cfile =~ '^\w\+\(::\w\+\)*$'
        return [cfile] + filter(copy(s:module_files), 'v:val =~ ''\c\_^' . prefix. "'")
    else
        return filter(copy(s:module_files), 'v:val =~ ''\c\_^' . prefix. "'")
    endif
endfunction


" Install current file and swap to alternate file...
nmap IP :!install -f %<CR>g


" Add *** as **/* on command-line...
cmap *** **/*


" Take off and nuke the entire buffer contents from space
" (It's the only way to be sure)
nmap XX 1GdG


" Insert cut marks...
nmap -- A<CR><CR><CR><ESC>k6i-----cut-----<ESC><CR>


" Indent/outdent current block...
nmap %% $>i}``
nmap $$ $<i}``


"=====[ Show help files in a new tab, plus add a shortcut for helpg ]==============

augroup HelpInTabs
    au!
    au BufEnter  *.txt   call HelpInNewTab()
augroup END

function! HelpInNewTab ()
    if &buftype == 'help'
        execute "normal \<C-W>T"
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

" Paste carefully in Normal mode...
nmap <silent> <C-P> :set paste<CR>
                   \!!pbtranspaste<CR>
                   \:set nopaste<CR>
                   \:set fileformat=unix<CR>

" When in Visual mode, paste over the selected region...
vmap <silent> <C-P> x:call TransPaste(visualmode())<CR>

function! TransPaste(type)
    " Remember the last yanked text...
    let reg_save = @@

    " Grab the MacOSX clipboard contents via a shell command...
    let clipboard = system("pbtranspaste")

    " Put them in the yank buffer...
    call setreg('@', clipboard, a:type)

    " Paste them...
    silent exe "normal! P"

    " Restore the previous yanked text...
    let @@ = reg_save
endfunction


" In Normal mode, yank the entire buffer...
nmap <silent> <C-C> :w !pbtranscopy<CR><CR>

" In Visual mode, yank the selection...
vmap <silent> <C-C> :<C-U>call TransCopy(visualmode(), 1)<CR>

function! TransCopy(type, ...)
    " Yank inclusively (but remember the previous setup)...
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    " Invoked from Visual mode, use '< and '> marks.
    if a:0
        silent exe "normal! `<" . a:type . "`>y"

    " Or yank a line, if requested...
    elseif a:type == 'line'
        silent exe "normal! '[V']y"

    " Or yank a block, if requested...
    elseif a:type == 'block'
        silent exe "normal! `[\<C-V>`]y"

    " Or else, just yank the range...
    else
        silent exe "normal! `[v`]y"
    endif

    " Send it to the MacOSX clipboard...
    call system("pbtranscopy", @@)

    " Restore the previous setup...
    let &selection = sel_save
    let @@ = reg_save
endfunction


"=====[ Convert file to different tabspacings ]=====================

function! NewTabSpacing (newtabsize)
    " Preserve expansion, if expanding...
    let was_expanded = &expandtab

    " But convert to tabs initially...
    normal TT

    " Change the tabsizing...
    execute "set ts="  . a:newtabsize
    execute "set sw="  . a:newtabsize

    " Update the formatting commands to mirror than new tabspacing...
    execute "map          F !Gformat -T" . a:newtabsize . " -"
    execute "map <silent> f !Gformat -T" . a:newtabsize . "<CR>"

    " Re-expand, if appropriate...
    if was_expanded
        normal TS
    endif
endfunction

" Note, these are all T-<SHIFTED-DIGIT>, which is easier to type...
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
iab    Jarrko  Jarkko
iab    jarrko  jarkko
iab      moer  more
iab  previosu  previous


"=====[ Programming support ]===================================

" Insert various shebang lines...
iab hbc #! /bin/csh
iab hbs #! /bin/sh
iab hbp #! /usr/bin/env perl<CR>use strict;<CR>use warnings;<CR>use 5.010;
iab hbr #! /Users/damian/bin/rakudo*<CR>use v6;

" Insert common Perl code structures...
iab udd use Data::Dumper 'Dumper';<CR>warn Dumper [];<ESC>hi
iab uds use Data::Show;<CR>show
iab ubm use Benchmark qw( cmpthese );<CR><CR>cmpthese -10, {<CR>};<ESC>O
iab usc use Smart::Comments;<CR>###
iab uts use Test::Simple 'no_plan';
iab utm use Test::More 'no_plan';
iab dbs $DB::single = 1;<ESC>


"=====[ Emphasize typical mistakes in Vim and Perl files ]=========

" Add a new high-visibility highlight combination...
highlight WHITE_ON_RED    ctermfg=white  ctermbg=red

" Emphasize undereferenced references...
call matchadd('WHITE_ON_RED', '_ref[ ]*[[{(]\|_ref[ ]*-[^>]')

" Emphasize typical mistakes a Perl hacker makes in .vim files...
augroup VimMistakes
    au!
    au BufEnter  *.vim,.vimrc   setlocal iskeyword+=:
    au BufEnter  *.vim,.vimrc   match WHITE_ON_RED /\_^\s*\zs\k\+\s*[+-.]\?==\@!\|\_^\s*elsif\|;\s*\_$/
augroup END


"=====[ Enable quickfix on perl programs ]=======================
" efm_perl.pl translates Perl error messages to the standard "%f:%l:%m" format

set makeprg=/Applications/Vim.app/Contents/Resources/vim/runtime/tools/efm_perl.pl\ -c\ %\ $*

au BufReadPost quickfix  setlocal number
                    \ |  setlocal nowrap
                    \ |  setlocal modifiable
                    \ |  silent! %s/^[^|]*\//.../
                    \ |  setlocal nomodifiable

nmap <silent> <RIGHT>         :cnext<CR>
nmap <silent> <RIGHT><RIGHT>  :cnf<CR>
nmap <silent> <LEFT>          :cprev<CR>
nmap <silent> <LEFT><LEFT>    :cpf<CR>


"=====[ Auto-setup for Perl scripts and modules ]===========

augroup Perl_Setup
    au!
    au BufNewFile *.p[lm] 0r !file_template <afile>
    au BufNewFile *.p[lm] /^[ \t]*[#].*implementation[ \t]\+here/
augroup END


"=====[ Proper syntax highlighting for Rakudo files ]===========

autocmd BufNewFile,BufRead  *   :call CheckForPerl6()

function! CheckForPerl6 ()
    if getline(1) =~ 'rakudo'
        setfiletype perl6
    endif
    if expand('<afile>:e') == 'pod6'
        highlight Pod6Block_Heading1 cterm=bold,underline
        highlight Pod6FC_Important cterm=underline

        nmap ;p :call Pod6_ToggleProofing()<CR>

        setfiletype pod6
        syntax enable
    endif
endfunction


"=====[ Tab handling ]======================================

set tabstop=4      "Tab indentation levels every four columns
set shiftwidth=4   "Indent/outdent by four columns
set expandtab      "Convert all tabs that are typed into spaces
set shiftround     "Always indent/outdent to nearest tabstop
set smarttab       "Use shiftwidths at left margin, tabstops everywhere else

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

call SmartcomAdd( '^\s*func',       "",   "tion!\<CR>endfunction\<UP> ",   )
call SmartcomAdd( '^\s*function!',  "",  "\<CR>endfunction\<UP> ",      )

call SmartcomAddAction( '^\s*use\s\+\k\+', "",
\                       'set complete=k~/.vim/perlmodules|set iskeyword+=:'
\)


" Make the completion popup look menu-ish on a Mac...
highlight  Pmenu        ctermbg=white   ctermfg=black
highlight  PmenuSel     ctermbg=blue    ctermfg=white   cterm=bold
highlight  PmenuSbar    ctermbg=grey    ctermfg=grey
highlight  PmenuThumb   ctermbg=blue    ctermfg=blue


"=====[ Extra completions for VimPoint files ]==========================

autocmd BufNewFile,BufRead  *.vpt   :call AddVimPointKeywords()

function! AddVimPointKeywords ()
    call SmartcomAddAction(
    \   '^=\k*', "", 'set complete=k~/.vim/VimPointKeywords|set iskeyword+=='
    \)
endfunction


"=====[ Grammar checking ]========================================

" List of problematic words...
let s:problem_words = [
\       "it's",  "its",
\       "were",  "we're",   "where",
\       "their", "they're", "there",
\       "your",  "you're",
\ ]

" OR them together to make a matchable pattern...
let s:problem_words_pat     = join(s:problem_words, '\|')
let s:problem_words_pat_str = substitute(s:problem_words_pat, "'", "''", 'g')

" Create a command that will match that pattern...
let s:words_matcher
\   = 'let w:check_grammar = matchadd(''BOLD'', ''\c\<\(' . s:problem_words_pat_str . '\)\>'')'

" Create a command that will find those words...
let s:words_finder
\   = '/\c\<\(' . s:problem_words_pat . '\)\>'

" Enbolden problematic words...
highlight BOLD  term=bold cterm=bold gui=bold

function! CheckGrammar ()
    " If we're turning the feature off...
    if exists('w:check_grammar')
        " Stop matching and highlighting the words...
        call matchdelete(w:check_grammar)

        " Clear the flag
        unlet w:check_grammar

        " Clear any search highlighting...
        return "nohlsearch"

    " If we're turning the feature on...
    else
        " Start matching and highlighting the words...
        exec s:words_matcher

        " Return a search command, to be executed by the mapping...
        return s:words_finder
    endif
endfunction

" Toggle grammar checking...
map <silent> ;g :exec CheckGrammar()<CR>


"=====[ Add or subtract comments ]===============================

" Work out what the comment character is, by filetype...
au BufNewFile,BufRead   *                                 let b:cmt = exists('b:cmt') ? b:cmt : ''
au FileType             *sh,awk,python,perl,perl6,ruby    let b:cmt = exists('b:cmt') ? b:cmt : '#'
au FileType             vim                               let b:cmt = exists('b:cmt') ? b:cmt : '"'

" Work out whether the line has a comment tehn reverse that condition...
function! ToggleComment ()
    " What's the comment character???
    let comment_char = exists('b:cmt') ? b:cmt : '#'

    " Grab the line and work out whether it's commented...
    let currline = getline(".")

    " If so, remove it and rewrite the line...
    if currline =~ '^' . comment_char
        let repline = substitute(currline, '^' . comment_char, "", "")
        call setline(".", repline)

    " Otherwise, insert it...
    else
        let repline = substitute(currline, '^', comment_char, "")
        call setline(".", repline)
    endif
endfunction

" Toggle comments down an entire visual selection of lines...
function! ToggleBlock () range
    " What's the comment character???
    let comment_char = exists('b:cmt') ? b:cmt : '#'

    " Start at the first line...
    let linenum = a:firstline

    " Get all the lines, and decide their comment state by examining the first...
    let currline = getline(a:firstline, a:lastline)
    if currline[0] =~ '^' . comment_char
        " If the first line is commented, decomment all...
        for line in currline
            let repline = substitute(line, '^' . comment_char, "", "")
            call setline(linenum, repline)
            let linenum += 1
        endfor
    else
        " Otherwise, encomment all...
        for line in currline
            let repline = substitute(line, '^\('. comment_char . '\)\?', comment_char, "")
            call setline(linenum, repline)
            let linenum += 1
        endfor
    endif
endfunction

" Set up the relevant mappings
nmap <silent> # :call ToggleComment()<CR>j0
vmap <silent> # :call ToggleBlock()<CR>


"=====[ Highlight cursor (plus row and column on request) ]===================

" Inverse highlighting for cursor...
highlight CursorInverse   term=inverse ctermfg=black ctermbg=white
call matchadd('CursorInverse', '\%#', 100)

" Need an invisible cursor column to make it update on every cursor move...
highlight clear CursorColumn
highlight CursorColumn term=none cterm=none
set cursorcolumn

" Toggle cursor row highlighting on request...
highlight CursorLine   term=bold ctermfg=black ctermbg=cyan  cterm=bold
map <silent> ;r :set cursorline!<CR>

" Toggle cursor column highlighting on request...
map <silent> ;c :silent call Toggle_CursorColumn('flip')<CR>

" Implement cursor toggle...
let g:cursorcolumn_visible = 0
function! Toggle_CursorColumn (requested_state)
    if a:requested_state == 'off' || g:cursorcolumn_visible && a:requested_state == 'flip'
        let g:cursorcolumn_visible = 0
        highlight clear CursorColumn
        highlight CursorColumn term=none cterm=none
    else
        let g:cursorcolumn_visible = 1
        highlight CursorColumn term=bold ctermfg=black ctermbg=cyan cterm=bold
    endif
endfunction

"=====[ Highlight spelling errors on request ]===================

set spelllang=en_au
map <silent> ;s :setlocal invspell<CR>


"======[ Create a toggle for the XML completion plugin ]=======

map ;x <Plug>XMLMatchToggle


"======[ Order-preserving uniqueness ]=========================

" Normalize the whitespace in a string...
function! TrimWS (str)
    " Remove whitespace fore and aft...
    let trimmed = substitute(a:str, '^\s\+\|\s\+$', '', 'g')

    " Then condense internal whitespaces...
    return substitute(trimmed, '\s\+', ' ', 'g')
endfunction

" Reduce a range of lines to only the unique ones, preserving order...
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

" Only in visual mode...
vmap  u :call Uniq()<CR>
vmap  U :call Uniq(1)<CR>


"====[ Make normalized search use NFKC ]=======

runtime plugin/normalized_search.vim
NormalizedSearchUsing ~/bin/NFKC


"====[ Configure handy Perl templates ]====================

"runtime plugin/fillabbr.vim
"
"Fillab  *.p[lm]   for    |for my $____ (_____) {
"                  \      |______
"
"Fillab  *.p[lm]   while  |while (_____) {
"                  \      |_____
"
"Fillab  *.p[lm]   if     |if (____) {
"                  \      |_____
"
"Fillab  *.p[lm]   alias  |alias my $_____ = ______;
"                  \      |___


"====[ Toggle between lists and bulleted lists ]======================

nmap <silent> ;l vip!list2bullets<CR>
vmap <silent> ;l !list2bullets<CR>


"====[ Make Gundo visualizer more usable ]============================

" Shut visualizer when a state is selected...
let g:gundo_close_on_revert = 1

" Use arrow keys to navigate...
let g:gundo_map_move_older  =  "\<DOWN>"
let g:gundo_map_move_newer  =  "\<UP>"

" No help required...
let g:gundo_help = 0

" Change the layout...
let g:gundo_right = 1

" Access via a simple mapping...
nmap ;u :GundoToggle<CR>
