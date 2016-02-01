"====[ Ensure autodoc'd plugins are supported ]===========

runtime plugin/_autodoc.vim


"====[ Work out what kind of file this is ]========

filetype plugin indent on

" .t bilong perl!!!

autocmd BufNewFile,BufRead  *.t                     setfiletype perl


"=====[ Comments are important ]==================

highlight Comment term=bold ctermfg=white


"=====[ Enable Nmap command for documented mappings ]================

runtime plugin/documap.vim


"====[ Edit and auto-update this config file and plugins ]==========

augroup VimReload
autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

Nmap <silent>  ;v   [Edit .vimrc]          :next $MYVIMRC<CR>
Nmap           ;vv  [Edit .vim/plugin/...] :next ~/.vim/plugin/


"====[ Edit my temporary working files ]====================

Nmap tt  [Edit temporary files] :next ~/tmp/temporary_file



"=====[ Edit files in local bin directory ]========

Nmap ;b  [Edit ~/bin/...]  :next ~/bin/


"====[ Go back to alternate file (but retain other g<whatever> mappings)]====

nmap g  :w<CR>:e #<CR>

function! s:conditional_nnoremap ( name )
    if maparg(a:name, 'n') == ""
        execute 'nnoremap  <unique> ' . a:name . ' ' . a:name
    endif
endfunction
call s:conditional_nnoremap( 'g,' )
call s:conditional_nnoremap( 'g;' )
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

" Make gn jump into visual block mode, instead if plain visual mode
nnoremap gn  gn<C-V>


"====[ Use persistent undo ]=================

if has('persistent_undo')
    " Save all undo files in a single location (less messy, more risky)...
    set undodir=$HOME/.VIM_UNDO_FILES

    " Save a lot of back-history...
    set undolevels=5000

    " Actually switch on persistent undo
    set undofile

endif


"====[ Goto last location in non-empty files ]=======

autocmd BufReadPost *  if line("'\"") > 1 && line("'\"") <= line("$")
                   \|     exe "normal! g`\""
                   \|  endif


"====[ I'm sick of typing :%s/.../.../g ]=======

Nmap S  [Shortcut for :s///g]  :%s//g<LEFT><LEFT>
vmap S                         :Blockwise s//g<LEFT><LEFT>

Nmap <expr> M  [Shortcut for :s/<last match>//g]  ':%s/' . @/ . '//g<LEFT><LEFT>'
vmap <expr> M                                     ':s/' . @/ . '//g<LEFT><LEFT>'

"====[ Toggle visibility of naughty characters ]============

" Make naughty characters visible...
" (uBB is right double angle, uB7 is middle dot)
exec "set lcs=tab:\uBB\uBB,trail:\uB7,nbsp:~"

augroup VisibleNaughtiness
    autocmd!
    autocmd BufEnter  *       set list
    autocmd BufEnter  *.txt   set nolist
    autocmd BufEnter  *.vp*   set nolist
    autocmd BufEnter  *       if !&modifiable
    autocmd BufEnter  *           set nolist
    autocmd BufEnter  *       endif
augroup END


"====[ Set up smarter search behaviour ]=======================

set incsearch       "Lookahead as search pattern is specified
set ignorecase      "Ignore case in all searches...
set smartcase       "...unless uppercase letters used

set hlsearch        "Highlight all matches
highlight clear Search
highlight       Search    ctermfg=White

"Delete in normal mode to switch off highlighting till next search and clear messages...
Nmap <silent> <BS> [Cancel highlighting]  :call HLNextOff() <BAR> :nohlsearch <BAR> :call VG_Show_CursorColumn('off')<CR>

"Double-delete to remove trailing whitespace...
Nmap <silent> <BS><BS>  [Remove trailing whitespace] mz:call TrimTrailingWS()<CR>`z

function! TrimTrailingWS ()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction


"====[ Handle encoding issues on a Macos terminal]============

set encoding=latin1

Nmap <silent> U  [Toggle UTF8]  :call ToggleUTF8()<CR><CR>:echo '[' . &fileencoding . ']'<CR>
Nmap <silent> UU [Toggle Unicode terminal]  :call ToggleTerminal()<CR><CR>

function! ToggleUTF8 ()
    if &fileencoding =~ 'utf-8'
        set fileencoding=latin1
        set termencoding=
        !osascript -e 'tell application "Terminal" to set current settings of front window to settings set "stdterminal"'
    else
        set fileencoding=utf8
        set termencoding=utf8
        !osascript -e 'tell application "Terminal" to set current settings of front window to settings set "stdterminal_unicode"'
    endif
endfunction

let g:UnicodeTerminal = 0
function! ToggleTerminal ()
    if g:UnicodeTerminal
        !osascript -e 'tell application "Terminal" to set current settings of front window to settings set "stdterminal"'
        let g:UnicodeTerminal = 0
        set termencoding=
        echo '[Latin1 terminal]'
    else
        !osascript -e 'tell application "Terminal" to set current settings of front window to settings set "stdterminal_unicode"'
        let g:UnicodeTerminal = 1
        set termencoding=utf8
        echo '[Unicode terminal]'
    endif
endfunction



"====[ Set background hint (if possible) ]=============

"if $VIMBACKGROUND != ""
"    exec 'set background=' . $VIMBACKGROUND
"else
"    set background=dark
"endif

set background=dark


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
"set cinwords = ""                           "But not for C-like keywords

"=======[ Fix smartindent stupidities ]============

set autoindent                              "Retain indentation on next line
set smartindent                             "Turn on autoindenting of blocks


nnoremap <silent> >> :call ShiftLine()<CR>|               "And no shift magic on comments

function! ShiftLine()
    set nosmartindent
    normal! >>
    set smartindent
endfunction



"====[ I hate modelines ]===================

set modelines=0


"=====[ Quicker access to Ex commands ]==================

nmap ; :
vmap ; :Blockwise<SPACE>


"=====[ Make Visual modes work better ]==================

" Visual Block mode is far more useful that Visual mode (so swap the commands)...
nnoremap v <C-V>
nnoremap <C-V> v

vnoremap v <C-V>
vnoremap <C-V> v

"Square up visual selections...
set virtualedit=block

" Make BS/DEL work as expected in visual modes (i.e. delete the selected text)...
vmap <BS> x

" Make vaa select the entire file...
vmap aa VGo1G


"=====[ Make arrow keys move visual blocks around ]======================

vmap <up>    <Plug>SchleppUp
vmap <down>  <Plug>SchleppDown
vmap <left>  <Plug>SchleppLeft
vmap <right> <Plug>SchleppRight

vmap D       <Plug>SchleppDupLeft
vmap <C-D>   <Plug>SchleppDupLeft


"=====[ Demo vim commands ]==============================

highlight WHITE_ON_BLACK ctermfg=white

Nmap <silent> ;; [Demonstrate Vimscript block] :call DemoCommand()<CR>
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

Nmap <silent> ;y [Toggle syntax highlighting]
                 \ : if exists("syntax_on") <BAR>
                 \    syntax off <BAR>
                 \ else <BAR>
                 \    syntax enable <BAR>
                 \ endif<CR>



"=====[ Always syntax highlight .patch and ToDo and .itn files ]=======================

augroup PatchHighlight
    autocmd!
    autocmd BufEnter  *.patch,*.diff  let b:syntax_was_on = exists("syntax_on")
    autocmd BufEnter  *.patch,*.diff  syntax enable
    autocmd BufLeave  *.patch,*.diff  if !getbufvar("%","syntax_was_on")
    autocmd BufLeave  *.patch,*.diff      syntax off
    autocmd BufLeave  *.patch,*.diff  endif
augroup END

augroup TODOHighlight
    autocmd!
    autocmd BufEnter  *.todo,todo,ToDo,TODO  let b:syntax_was_on = exists("syntax_on")
    autocmd BufEnter  *.todo,todo,ToDo,TODO  syntax enable
    autocmd BufLeave  *.todo,todo,ToDo,TODO  if !getbufvar("%","syntax_was_on")
    autocmd BufLeave  *.todo,todo,ToDo,TODO      syntax off
    autocmd BufLeave  *.todo,todo,ToDo,TODO  endif
augroup END

augroup ITNHighlight
    autocmd!
    autocmd BufEnter  *.itn   let b:syntax_was_on = exists("syntax_on")
    autocmd BufEnter  *.itn   syntax enable
    autocmd BufEnter  *.itn   set syntax=itn
    autocmd BufLeave  *.itn   if !getbufvar("%","syntax_was_on")
    autocmd BufLeave  *.itn       syntax off
    autocmd BufLeave  *.itn   endif
augroup END


"=====[ Configure % key (via matchit plugin) ]==============================

" Match angle brackets...
set matchpairs+=<:>,«:»

" Match double-angles, XML tags and Perl keywords...
let TO = ':'
let OR = ','
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
"           | +--Remember marks for last 500 files
"           | |    +--Remember up to 10000 lines in each register
"           | |    |      +--Remember up to 1MB in each register
"           | |    |      |     +--Remember last 1000 search patterns
"           | |    |      |     |     +---Remember last 1000 commands
"           | |    |      |     |     |
"           v v    v      v     v     v
set viminfo=h,'500,<10000,s1000,/1000,:1000

set backspace=indent,eol,start      "BS past autoindents, line boundaries,
                                    "     and even the start of insertion

set fileformats=unix,mac,dos        "Handle Mac and DOS line-endings
                                    "but prefer Unix endings


set wildmode=list:longest,full      "Show list of completions
                                    "  and complete as much as possible,
                                    "  then iterate full completions

set infercase                       "Adjust completions to match case

set noshowmode                      "Suppress mode change messages

set updatecount=10                  "Save buffer every 10 chars typed


" Keycodes and maps timeout in 3/10 sec...
set timeout timeoutlen=300 ttimeoutlen=300

set thesaurus+=~/Documents/thesaurus    "Add thesaurus file for ^X^T
set dictionary+=~/Documents/dictionary  "Add dictionary file for ^X^K


set scrolloff=2                     "Scroll when 2 lines from top/bottom



"====[ Simplify textfile backups ]============================================

" Back up the current file
Nmap BB [Back up current file]  :!bak -q %<CR><CR>:echomsg "Backed up" expand('%')<CR>


"=====[ Remap various keys to something more useful ]========================

" Use space to jump down a page (like browsers do)...
nnoremap   <Space> <PageDown>
vnoremap   <Space> <PageDown>

" Forward/back one file...
nmap <silent><expr> <DOWN> File_advance('next')
nmap <silent><expr> <UP>   File_advance('prev')

function! File_advance (dir)
    if a:dir == 'next'
        return argidx() < argc() - 1 ? ":next\<CR>0"
        \                            : ":echohl Comment|:echo 'At last file'|echohl NONE\<CR>"
    elseif a:dir == 'prev'
        return argidx() > 0          ? ":prev\<CR>0"
        \                            : ":echohl Comment|:echo 'At first file'|echohl NONE\<CR>"
    else
        echoerr "Unknown direction for file advance: " . a:dir
    endif
endfunction

" Format file with autoformat (capitalize to specify options)...
nmap          F  !Gformat -T4 -
nmap <silent> f  !Gformat -T4<CR>
nmap          ff r<CR>fgej
vmap          F :!format -T4 -all -
vmap <silent> f :!format -T4 -all<CR>

" Install current file and swap to alternate file...
Nmap IP [Install current file and swap to alternate] :!install -f %<CR>


" Add *** as **/* on command-line...
cmap *** **/*


" Take off and nuke the entire buffer contents from space
" (It's the only way to be sure)...
nmap XX 1GdG

" Replace the current buffer with a copy of the most recent file...

nmap RR XX:0r#<CR><C-G>

" Insert cut marks...
nmap -- A<CR><CR><CR><ESC>k6i-----cut-----<ESC><CR>


" Indent/outdent current block...
nmap %% $>i}``
nmap $$ $<i}``


" =====[ Perl programming support ]===========================

" Execute Perl file...
nmap <silent> W  :!clear;echo;echo;(script -q ~/tmp/script_$$ polyperl %; if (-s ~/tmp/script_$$) then; echo; echo; echo; getraw; endif; rm -f ~/tmp/script_$$ )<CR><CR>

" Execute Perl file (output to pager)...
nmap E :!polyperl -m %<CR>

" Execute Perl file (in debugger)...
nmap Q :!polyperl -d %<CR>

" Execute Perl file (in regex debugger)...
nmap ;r :!rxrx %<CR>

" Format file with perltidy...
Nmap ;p [Perltidy the current buffer]  1G!Gperltidy<CR>

" Show what changes perltidy would make...
Nmap ;pp [Perltidy to the current buffer (as a diff)]  :call Perltidy_diff()<CR>

function! Perltidy_diff ()
    " Work out what the tidied file will be called...
    let perl_file = expand( '%' )
    let tidy_file = perl_file . '.tdy'

    call system( 'perltidy -nst ' . perl_file . ' -o ' . tidy_file )

    " Add the diff to the right of the current window...
    set splitright
    exe ":vertical diffsplit " . tidy_file

    " Clean up the tidied version...
    call delete(tidy_file)
endfunction

" Run perldoc with smarter completion...
Nmap <expr> ?? [Go to documentation] CallPerldoc()
set keywordprg=pd

function! CallPerldoc ()
    " When editing Vim files, revert to :help...
    if &filetype == 'vim' || &buftype == 'help'
        return ":help "

    " Otherwise use Perldoc...
    else
        let target = matchstr(expand('<cfile>'), '\w\+\(::\w\+\)*')
        set wildmode=list:full
        return ":Perldoc "
    endif
endfunction

"Complete perldoc requests with names of installed Perl modules
command! -nargs=? -complete=customlist,CompletePerlModuleNames Perldoc  call Perldoc_impl(<q-args>)

"Undo the special wildmoding and then execute the requested perdoc lookup...
function! Perldoc_impl (args)
    set wildmode=list:longest,full
    if empty(a:args)
        exec '!pd %'
    else
        exec '!pd ' . a:args
    endif
endfunction

" Compile the list of installed Perl modules (and include the name under the cursor)...
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


" Handle Perl include files better...
"set include=^\\s*use\\s\\+\\zs\\k\\+\\ze
"set includeexpr=substitute(v:fname,'::','/','g')
"set suffixesadd=.pm
"execute 'set path+=' . substitute($PERL5LIB, ':', ',', 'g')


"Adjust keyword characters to match Perlish identifiers...
set iskeyword+=$
set iskeyword+=%
set iskeyword+=@-@
set iskeyword+=:
set iskeyword-=,


" Insert common Perl code structures...

iab udd use Data::Dumper 'Dumper';<CR>warn Dumper [];<ESC>hi
iab udv use Dumpvalue;<CR>Dumpvalue->new->dumpValues();<ESC>hi
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
let g:VimMistakes
\   =     '\_^\s*\zs\%(my\s\+\)\?\%(\k:\)\?\k\+\%(\[.\{-}\]\)\?\s*[+-.]\?=[=>~]\@!'
\   . '\|'
\   .     '\_^\s*\zselsif'
\   . '\|'
\   .     ';\s*\_$'
\   . '\|'
\   .     '\_^\s*\zs#.*'
\   . '\|'
\   .     '\_^\s*\zs\k\+('

let g:VimMistakesID = 668
augroup VimMistakes
    autocmd!
    autocmd BufEnter  *.vim,*.vimrc   call VimMistakes_AddMatch()
    autocmd BufLeave  *.vim,*.vimrc   call VimMistakes_ClearMatch()
augroup END

function! VimMistakes_AddMatch ()
    try | call matchadd('WHITE_ON_RED',g:VimMistakes,10,g:VimMistakesID) | catch | endtry
endfunction

function! VimMistakes_ClearMatch ()
    try | call matchdelete(g:VimMistakesID) | catch | endtry
endfunction


"=====[ Enable quickfix on Perl programs ]=======================

Nmap ;m [Run :make and any tests on a Perl file]  :make<CR><CR><CR>:call PerlMake_Cleanup()<CR>

function! PerlMake_Cleanup ()
    " If there are errors, show the first of them...
    if !empty(getqflist())
        cc

    " Otherwise, run the test suite as well...
    else
        call RunPerlTests()
    endif
endfunction

set makeprg=polyperl\ -vc\ %\ $*

augroup PerlMake
    autocmd!
    autocmd BufReadPost quickfix  setlocal number
                             \ |  setlocal nowrap
                             \ |  setlocal modifiable
                             \ |  silent! %s/^[^|]*\//.../
                             \ |  setlocal nomodifiable
augroup END


" Make it easy to navigate errors (and vimgreps)...

nmap <silent> <RIGHT>         :cnext<CR>
nmap <silent> <RIGHT><RIGHT>  :cnf<CR><C-G>
nmap <silent> <LEFT>          :cprev<CR>
nmap <silent> <LEFT><LEFT>    :cpf<CR><C-G>


"=====[ Run a Perl module's test suite ]=========================

let g:PerlTests_program       = 'perltests'   " ...What to call
let g:PerlTests_search_height = 5             " ...How far up to search
let g:PerlTests_test_dir      = '/t'          " ...Where to look for tests

augroup Perl_Tests
    autocmd!
    autocmd BufEnter *.p[lm]  Nmap <buffer> ;t [Run local test suite] :call RunPerlTests()<CR>
    autocmd BufEnter *.t      Nmap <buffer> ;t [Run local test suite] :call RunPerlTests()<CR>
augroup END

function! RunPerlTests ()
    " Start in the current directory...
    let dir = expand('%:h')

    " Walk up through parent directories, looking for a test directory...
    for n in range(g:PerlTests_search_height)
        " When found...
        if isdirectory(dir . g:PerlTests_test_dir)
            " Go there...
            silent exec 'cd ' . dir

            " Run the tests...
            exec ':!' . g:PerlTests_program

            " Return to the previous directory...
            silent cd -
            return
        endif

        " Otherwise, keep looking up the directory tree...
        let dir = dir . '/..'
    endfor

    " If not found, report the failure...
    echohl WarningMsg
    echomsg "Couldn't find a suitable" g:PerlTests_test_dir '(tried' g:PerlTests_search_height 'levels up)'
    echohl None
endfunction


"=====[ Auto-setup for Perl scripts and modules ]===========

augroup Perl_Setup
    autocmd!
    autocmd BufNewFile *.p[lm] 0r !file_template <afile>
    autocmd BufNewFile *.p[lm] /^[ \t]*[#].*implementation[ \t]\+here/
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

        setfiletype pod6
        syntax enable
    endif
endfunction


" =====[ Smart completion via <TAB> and <S-TAB> ]=============

runtime plugin/smartcom.vim

" Add extra completions (mainly for Perl programming)...

let ANYTHING = ""
let NOTHING  = ""
let EOL      = '\s*$'

                " Left     Right      Insert                             Reset cursor
                " =====    =====      ===============================    ============
call SmartcomAdd( '<<',    ANYTHING,  '>>',                              {'restore':1} )
call SmartcomAdd( '<<',    '>>',      "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '«',     ANYTHING,  '»',                               {'restore':1} )
call SmartcomAdd( '«',     '»',       "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '{{',    ANYTHING,  '}}',                              {'restore':1} )
call SmartcomAdd( '{{',    '}}',      NOTHING,                                         )
call SmartcomAdd( 'qr{',   ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'qr{',   '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>"                 )
call SmartcomAdd( 'm{',    ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'm{',    '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( 's{',    ANYTHING,  '}{}xms',                          {'restore':1} )
call SmartcomAdd( 's{',    '}{}xms',  "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( '\*\*',  ANYTHING,  '**',                              {'restore':1} )
call SmartcomAdd( '\*\*',  '\*\*',    NOTHING,                                         )

" Handle single : correctly...
call SmartcomAdd( '^:\|[^:]:',  EOL,  "\<TAB>" )

" In the middle of a keyword: delete the rest of the keyword before completing...
                " Left     Right                    Insert
                " =====    =====                    =======================
"call SmartcomAdd( '\k',    '\k\+\%(\k\|\n\)\@!',    "\<C-O>cw\<C-X>\<C-N>",           )
"call SmartcomAdd( '\k',    '\k\+\_$',               "\<C-O>cw\<C-X>\<C-N>",           )

"After an alignable, align...
function! AlignOnPat (pat)
    return "\<ESC>:call EQAS_Align('nmap',{'pattern':'" . a:pat . "'})\<CR>/" . a:pat . "/e\<CR>:nohlsearch\<CR>a\<SPACE>"
endfunction
                " Left         Right        Insert
                " ==========   =====        =============================
call SmartcomAdd( '=',         ANYTHING,    "\<ESC>:call EQAS_Align('nmap')\<CR>/=/\<CR>:nohlsearch\<CR>a\<SPACE>")
call SmartcomAdd( '=>',        ANYTHING,    AlignOnPat('=>'))
call SmartcomAdd( '\s#',       ANYTHING,    AlignOnPat('\%(\S\s*\)\@<= #'))
call SmartcomAdd( '[''"]\s*:', ANYTHING,    AlignOnPat(':'),                   {'filetype':'vim'} )
call SmartcomAdd( ':',         ANYTHING,    "\<TAB>",                          {'filetype':'vim'} )


                " Left         Right   Insert                                  Where
                " ==========   =====   =============================           ===================
" Vim keywords...
call SmartcomAdd( '^\s*func\%[tion]',
\                              EOL,    "\<C-W>function!\<CR>endfunction\<UP> ",{'filetype':'vim'} )
call SmartcomAdd( '^\s*for',   EOL,    " ___ in ___\n___\n\<C-D>endfor\n___",  {'filetype':'vim'} )
call SmartcomAdd( '^\s*if',    EOL,    " ___ \n___\n\<C-D>endif\n___",         {'filetype':'vim'} )
call SmartcomAdd( '^\s*while', EOL,    " ___ \n___\n\<C-D>endwhile\n___",      {'filetype':'vim'} )
call SmartcomAdd( '^\s*try',   EOL,    "\n\t___\n\<C-D>catch\n\t___\n\<C-D>endtry\n___", {'filetype':'vim'} )

" Perl keywords...
call SmartcomAdd( '^\s*for',   EOL,    " my $___ (___) {\n___\n}\n___",        {'filetype':'perl'} )
call SmartcomAdd( '^\s*if',    EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*while', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*given', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*when',  EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )

" Complete Perl module loads with the names of Perl modules...
call SmartcomAddAction( '^\s*use\s\+\k\+', "",
\                       'set complete=k~/.vim/perlmodules|set iskeyword+=:'
\)


"=====[ General programming support ]===================================

" Insert various shebang lines...
iab hbc #! /bin/csh
iab hbs #! /bin/sh
iab hbp #! /usr/bin/env polyperl<CR>use 5.014; use warnings; use autodie;<CR>
iab hb6 #! /usr/bin/env perl6<CR>use v6;


" Execute current file polymorphically...
Nmap ,, [Execute current file] :w<CR>:!clear;echo;echo;run %<CR>
Nmap ,,, [Debug current file]  :w<CR>:!clear;echo;echo;run -d %<CR>


"=====[ Show help files in a new tab, plus add a shortcut for helpg ]==============

let g:help_in_tabs = 1

nmap <silent> H  :let g:help_in_tabs = !g:help_in_tabs<CR>

"Only apply to .txt files...
augroup HelpInTabs
    autocmd!
    autocmd BufEnter  *.txt   call HelpInNewTab()
augroup END

"Only apply to help files...
function! HelpInNewTab ()
    if &buftype == 'help' && g:help_in_tabs
        "Convert the help window to a tab...
        execute "normal \<C-W>T"
    endif
endfunction

"Simulate a regular cmap, but only if the expansion starts at column 1...
function! CommandExpandAtCol1 (from, to)
    if strlen(getcmdline()) || getcmdtype() != ':'
        return a:from
    else
        return a:to
    endif
endfunction

"Expand hh -> helpg...
cmap <expr> hh CommandExpandAtCol1('hh','helpg ')


"=====[ Cut and paste from MacOSX clipboard ]====================

" Paste carefully in Normal mode...
nmap <silent> <C-P> :set paste<CR>
                   \:let b:prevlen = len(getline(0,'$'))<CR>
                   \!!pbtranspaste<CR>
                   \:set nopaste<CR>
                   \:set fileformat=unix<CR>
                   \mv
                   \:exec 'normal ' . (len(getline(0,'$')) - b:prevlen) . 'j'<CR>
                   \V`v

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

function! InferTabspacing ()
    return min(filter(map(getline(1,'$'),'strlen(matchstr(v:val, ''^\s\+''))'),'v:val != 0'))
endfunction

function! NewTabSpacing (newtabsize)
    " Determine apparent tabspacing, if necessary...
    if &tabstop == 4
        let &tabstop = InferTabspacing()
    endif

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
nmap <silent> T@ :call NewTabSpacing(2)<CR>
nmap <silent> T# :call NewTabSpacing(3)<CR>
nmap <silent> T$ :call NewTabSpacing(4)<CR>
nmap <silent> T% :call NewTabSpacing(5)<CR>
nmap <silent> T^ :call NewTabSpacing(6)<CR>
nmap <silent> T& :call NewTabSpacing(7)<CR>
nmap <silent> T* :call NewTabSpacing(8)<CR>
nmap <silent> T( :call NewTabSpacing(9)<CR>

" Convert to/from spaces/tabs...
nmap <silent> TS :set   expandtab<CR>:%retab!<CR>
nmap <silent> TT :set noexpandtab<CR>:%retab!<CR>
nmap <silent> TF TST$


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


"=====[ Tab handling ]======================================

set tabstop=4      "Tab indentation levels every four columns
set shiftwidth=4   "Indent/outdent by four columns
set expandtab      "Convert all tabs that are typed into spaces
set shiftround     "Always indent/outdent to nearest tabstop
set smarttab       "Use shiftwidths at left margin, tabstops everywhere else


" Make the completion popup look menu-ish on a Mac...
highlight  Pmenu        ctermbg=white   ctermfg=black
highlight  PmenuSel     ctermbg=blue    ctermfg=white   cterm=bold
highlight  PmenuSbar    ctermbg=grey    ctermfg=grey
highlight  PmenuThumb   ctermbg=blue    ctermfg=blue

" Make diffs less glaringly ugly...
highlight DiffAdd     cterm=bold ctermfg=green     ctermbg=black
highlight DiffChange  cterm=bold ctermfg=grey      ctermbg=black
highlight DiffDelete  cterm=bold ctermfg=black     ctermbg=black
highlight DiffText    cterm=bold ctermfg=magenta   ctermbg=black

"=====[ Extra completions for VimPoint files ]==========================

autocmd BufNewFile,BufRead  *.vpt   :call AddVimPointKeywords()

function! AddVimPointKeywords ()
    call SmartcomAddAction(
    \   '^=\k*', "", 'set complete=k~/.vim/VimPointKeywords|set iskeyword+=='
    \)
endfunction


" "=====[ Grammar checking ]========================================

highlight GRAMMARIAN_ERRORS_MSG   ctermfg=red   cterm=bold
highlight GRAMMARIAN_CAUTIONS_MSG ctermfg=white cterm=bold


"=====[ Add or subtract comments ]===============================

" Work out what the comment character is, by filetype...
autocmd FileType             *sh,awk,python,perl,perl6,ruby    let b:cmt = exists('b:cmt') ? b:cmt : '#'
autocmd FileType             vim                               let b:cmt = exists('b:cmt') ? b:cmt : '"'
autocmd BufNewFile,BufRead   *.vim,.vimrc                      let b:cmt = exists('b:cmt') ? b:cmt : '"'
autocmd BufNewFile,BufRead   *                                 let b:cmt = exists('b:cmt') ? b:cmt : '#'
autocmd BufNewFile,BufRead   *.p[lm],.t                        let b:cmt = exists('b:cmt') ? b:cmt : '#'

" Work out whether the line has a comment then reverse that condition...
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


"=====[ Highlight cursor ]===================

" Inverse highlighting for cursor...
highlight CursorInverse   term=inverse ctermfg=black ctermbg=white

" Set up highlighter at high priority (i.e. 100)
call matchadd('CursorInverse', '\%#', 100)

" Need an invisible cursor column to make it update on every cursor move...
" (via the visualguide.vim plugin, so as to play nice)
runtime plugin/visualsmartia.vim
call VG_Show_CursorColumn('off')


"=====[ Highlight row and column on request ]===================

" Toggle cursor row highlighting on request...
highlight CursorLine   term=bold ctermfg=black ctermbg=cyan  cterm=bold
Nmap <silent> ;R [Toggle cursor line highlighting] :set cursorline!<CR>

" Toggle cursor column highlighting on request...
" (via visualguide.vim plugin, so as to play nice)
nmap <silent> \  :silent call VG_Show_CursorColumn('flip')<CR>
vmap <silent> \  :<C-W>silent call VG_Show_CursorColumn('flip')<CR>gv
imap <silent> <C-\>  <C-O>:silent call VG_Show_CursorColumn('flip')<CR>


"=====[ Highlight spelling errors on request ]===================

set spelllang=en_au
Nmap <silent> ;s  [Toggle spell-checking]               :set invspell spelllang=en<CR>
Nmap <silent> ;ss [Toggle Basic English spell-checking] :set    spell spelllang=en-basic<CR>


"======[ Create a toggle for the XML completion plugin ]=======

Nmap ;x [Toggle XML completion] <Plug>XMLMatchToggle


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
vmap  q :call Uniq()<CR>
vmap  Q :call Uniq('ignore whitespace')<CR>


"====[ Make normalized search use NFKC ]=======

runtime plugin/normalized_search.vim
NormalizedSearchUsing ~/bin/NFKC



"====[ Regenerate help tags when directly editing a help file ]=================

augroup HelpTags
    au!
    autocmd BufWritePost ~/.vim/doc/*   :helptags ~/.vim/doc
augroup END


"====[ Formatting for .lei files ]=======================================

augroup LEI
    autocmd!
    autocmd BufEnter *.lei  nmap =  vip!sort -bdfu<CR>vip:call LEI_format()<CR>
augroup END

function! LEI_format () range
    let [from, to] = [a:firstline, a:lastline]

    " Acquire data...
    let lines = getline(from, to)

    " Ignore comments and category descriptions...
    if lines[0] =~ '^\S'
        return
    endif

    " Subdivide each line into singular/plural/classical plural columns...
    let fields = []
    for line in lines
        let new_fields = split(line, '\s*\(|\|=>\)\s*')
        call add(fields, ["","",""])
        for col_num in [0,1,2]
            let fields[-1][col_num] = get(new_fields, col_num, "")
        endfor
    endfor

    " Work out how wide the columns need to be...
    let max_width = [0,0]
    for field_num in range(len(fields))
        for col_num in [0,1]
            let max_width[col_num] = max([max_width[col_num], strlen(fields[field_num][col_num])])
        endfor
    endfor

    " Are there any classical alternatives???
    let has_classical = match(lines, '|') >= 0
    let field_template
    \   = has_classical
     \    ? '%-' . max_width[0] . 's  =>  %-' . max_width[1] . 's  |  %s'
      \   : '%-' . max_width[0] . 's  =>  %-s'

    " Reformat each line...
    for field_num in range(len(fields))
        let updated_line
        \   = has_classical
         \    ? printf(field_template, fields[field_num][0], fields[field_num][1], fields[field_num][2])
          \   : printf(field_template, fields[field_num][0], fields[field_num][1])
        call setline(from + field_num, substitute(updated_line,'\s*$','',''))
    endfor
endfunction


"=====[ Search folding ]=====================

" Don't start new buffers folded
set foldlevelstart=99

" Highlight folds
highlight Folded  ctermfg=cyan ctermbg=black

" Toggle on and off...
nmap <silent> <expr>  zz  FS_ToggleFoldAroundSearch({'context':1})

" Show only sub defns (and maybe comments)...
let perl_sub_pat = '^\s*\%(sub\|func\|method\|package\)\s\+\k\+'
let vim_sub_pat  = '^\s*fu\%[nction!]\s\+\k\+'
augroup FoldSub
    autocmd!
    autocmd BufEnter * nmap <silent> <expr>  zp  FS_FoldAroundTarget(perl_sub_pat,{'context':1})
    autocmd BufEnter * nmap <silent> <expr>  za  FS_FoldAroundTarget(perl_sub_pat.'\\|^\s*#.*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  zp  FS_FoldAroundTarget(vim_sub_pat,{'context':1})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  za  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter * nmap <silent> <expr>             zv  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
augroup END

" Show only C #includes...
nmap <silent> <expr>  zu  FS_FoldAroundTarget('^\s*use\s\+\S.*;',{'context':1})


"====[ Do a command, then restore the cursor ]======

command! -nargs=+ -complete=command Static  call Static_impl(<q-args>)

function! Static_impl (cmd)
    exec a:cmd
    normal ``
endfunction


"====[ Show when lines extend past column 80 ]=================================>-<=====================

highlight ColorColumn ctermfg=208 ctermbg=Black

function! MarkMargin (on)
    if exists('b:MarkMargin')
        try
            call matchdelete(b:MarkMargin)
        catch /./
        endtry
        unlet b:MarkMargin
    endif
    if a:on
        let b:MarkMargin = matchadd('ColorColumn', '\%81v\s*\S', 100)
    endif
endfunction

augroup MarkMargin
    autocmd!
    autocmd  BufEnter  *       :call MarkMargin(1)
    autocmd  BufEnter  *.vp*   :call MarkMargin(0)
augroup END


"====[ Accelerated up and down on wrapped lines ]============

"nnoremap  j  gj
"nnoremap  k  gk
nmap j <Plug>(accelerated_jk_gj)
nmap k <Plug>(accelerated_jk_gk)


"====[ Pathogen support ]======================

call pathogen#infect()
call pathogen#helptags()


"====[ Mapping to analyse a list of numbers ]====================

" Need to load this early, so we can override its nmapped ++
runtime plugin/eqalignsimple.vim

vmap <silent><expr> ++  VMATH_YankAndAnalyse()
nmap <silent>       ++  vip++


"====[ Configure eqalignsimple ]=================================
"
"EQAS_align('\S:',         '',   '\s')
"EQAS_align('[[:punct:]]', '',   '\s')



"====[ Make digraphs easier to get right (various versions) ]=================

inoremap <expr>  <C-J>       HUDG_GetDigraph()
inoremap <expr>  <C-K>       BDG_GetDigraph()
inoremap <expr>  <C-L>       HUDigraphs()

function! HUDigraphs ()
    digraphs
    call getchar()
    return "\<C-K>"
endfunction


"====[ Extend a previous match ]=====================================

nnoremap //   /<C-R>/
nnoremap ///  /<C-R>/\<BAR>



"====[ Toggle between lists and bulleted lists ]======================

Nmap <silent> ;l [Toggle list format (bullets <-> commas)]  :call ListTrans_toggle_format()<CR>f
vmap <silent> ;l                                            :call ListTrans_toggle_format('visual')<CR>f


"=====[ Select a table column in visual mode ]========================

vnoremap <silent><expr> c  VTC_select()


"=====[ Make * respect smartcase and also set @/ (to enable 'n' and 'N') ]======

nmap *  :let @/ = '\<'.expand('<cword>').'\>' ==? @/ ? @/ : '\<'.expand('<cword>').'\>'<CR>n


"=====[ Much smarter "edit next file" command ]=======================

nmap <silent><expr>  e  g:GTF_goto_file()



"=====[ Smarter interstitial completions of identifiers ]=============
"
" When autocompleting within an identifier, prevent duplications...

augroup Undouble_Completions
    autocmd!
    autocmd CompleteDone *  call Undouble_Completions()
augroup None

function! Undouble_Completions ()
    let col  = getpos('.')[2]
    let line = getline('.')
    call setline('.', substitute(line, '\(\k\+\)\%'.col.'c\zs\1', '', ''))
endfunction


"=====[ Autocomplete Perl code ]===========================
" (Note insertion of X<C-H># to overcome smartindent's mania for C-like #'s)

"inoremap <silent> >  ><ESC>:call SmartArrow()<CR>a
"inoremap <silent> #  X<C-H>#<C-R>=SmartOctothorpe()<CR>
inoremap <silent> #  X<C-H>#

function! SmartArrow ()
    if &filetype =~ '^perl' && search('=\%#>', 'bn', line('.'))
        mark m
        let [bufnum, lnum, col, off] = getpos('.')
        let prefix = matchstr(getline('.'), '^.*=>\%'.(col+1).'v')
        let arrow_count = len(split(prefix,'=>'))
        let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline  = search('^\%('. indent_pat . '\)\@!\|^\s*$','bnW') + 1
        let lastline   = search('^\%('. indent_pat . '\)\@!\|^\s*$', 'nW') - 1
        exec firstline.','.lastline.'!perltidyarrows'
        normal 'm
        while arrow_count
            call search('=>','e',lnum)
            let arrow_count -= 1
        endwhile
    endif
endfunction

"function! SmartArrow ()
"    if &filetype =~ '^perl' && search('^.*\S.*\s=>\%#$', 'bn', line('.'))
"        return "\<ESC>"
"            \. ":call EQAS_Align('nmap',{'pattern':'=>'})\<CR>"
"            \. ":call EQAS_Align('nmap',{'pattern':'\\%(\\S\\s*\\)\\@<=#'})\<CR>"
"            \. "$a"
"    else
"        return ""
"    endif
"endfunction
"
function! SmartOctothorpe ()
    if &filetype =~ '^perl' && search('^.\{-}\S.\{-}\s#\%#$','bn')
        return "\<ESC>"
            \. ":call EQAS_Align('nmap',{'pattern':'\\%(\\S\\s\\)\\@<=#'})\<CR>"
            \. "$s"
    else
        return ""
    endif
endfunction


"=====[ Improve ruler with optional word counts]=================================

let g:BRF_new_rulerformat = '%22(%l,%v %= %{BRF_WordCount()}w  %P%)'
let g:BRF_interval = 1

function! BRF_WordCount()
    " Skip an increasing percentage of increasingly expensive updates, as the file gets longer
    let g:BRF_interval += 1
    if exists("b:BRF_wordcount")
        if g:BRF_interval < b:BRF_wordcount / 500
            return '~' . b:BRF_wordcount
        endif
        let g:BRF_interval = 1
    endif

    " Otherwise, recount the file...
    if &modified || !exists("b:BRF_wordcount")
        let lines = join(getline(1,'$'), ' ')
        let lines = substitute(lines, '\a[''-]\a',      'X', 'g')
        let lines = substitute(lines, '[[:alnum:]]\+',  'X', 'g')
        let lines = substitute(lines, '[^[:alnum:]]\+', '',  'g')
        let b:BRF_wordcount = strlen(lines)
    endif

    " Return the precise count...
    return b:BRF_wordcount
endfunction

function! BRF_ToggleRuler ()
    if strlen(&rulerformat)
        let &rulerformat = ''
    else
        let &rulerformat = g:BRF_new_rulerformat
    endif
    set ruler
    redraw
endfunction

nmap <silent> ;w :silent call BRF_ToggleRuler()<CR><C-L>

let &rulerformat = g:BRF_new_rulerformat
set ruler


"======[ Fix colourscheme for 256 colours ]============================

highlight Visual       ctermfg=Yellow ctermbg=26    " 26 = Dusty blue background
highlight SpecialKey   cterm=bold ctermfg=Blue


"======[ Add a Y command for incremental yank in Visual mode ]==============

vnoremap <silent>       Y   <ESC>:silent let @y = @"<CR>gv"Yy:silent let @" = @y<CR>
nnoremap <silent>       YY  :call Incremental_YY()<CR>
nnoremap <silent><expr> Y         Incremental_Y()

function! Incremental_YY () range
    let @" .= join(getline(a:firstline, a:lastline), "\n") . "\n"
endfunction

function! Incremental_Y ()
    let motion = nr2char(getchar())
    if motion == 'Y'
        call Incremental_YY()
        return
    elseif motion =~ '[ia]'
        let motion .= nr2char(getchar())
    elseif motion =~ '[/?]'
        let motion .= input(motion) . "\<CR>"
    endif

    let @y = @"
    return '"Yy' . motion . ':let @" = @y' . "\<CR>"
endfunction


"======[ Add a $$ command in Visual mode ]==============================

vmap <silent>       ]   $"yygv_$
vmap <silent><expr> _$  Under_dollar_visual()

function! Under_dollar_visual ()
    " Locate block being shifted...
    let maxcol = max(map(split(@y, "\n"), 'strlen(v:val)')) + getpos("'<")[2] - 2

    " Return the selction that does the job...
    return maxcol . '|'
endfunction


"=====[ Diff against disk ]==========================================

map <silent> zd :silent call DC_DiffChanges()<CR>

" Change the fold marker to something more useful
function! DC_LineNumberOnly ()
    if v:foldstart == 1
        return '(No difference)'
    else
        return 'line ' . v:foldstart . ':'
    endif
endfunction

" Track each buffer's initial state
augroup DC_TrackInitial
    autocmd!
    autocmd BufReadPost,BufNewFile  *   if !exists('b:DC_initial_state')
    autocmd BufReadPost,BufNewFile  *       let b:DC_initial_state = getline(1,'$')
    autocmd BufReadPost,BufNewFile  *   endif
augroup END

highlight DC_DEEMPHASIZED ctermfg=grey

function! DC_DiffChanges ()
    diffthis
    highlight Normal ctermfg=grey
    let initial_state = b:DC_initial_state
    set diffopt=context:1000000,filler,foldcolumn:0
    set fillchars=fold:\
    set foldcolumn=0
    setlocal foldtext=DC_LineNumberOnly()
    aboveleft vnew
    normal 0
    silent call setline(1, initial_state)
    diffthis
    set diffopt=context:1000000,filler,foldcolumn:0
    set fillchars=fold:\
    set foldcolumn=0
    setlocal foldtext=DC_LineNumberOnly()
    nmap <silent><buffer> zd :diffoff<CR>:q!<CR>:set diffopt& fillchars& foldcolumn=0<CR>:set nodiff<CR>:highlight Normal ctermfg=NONE<CR>
endfunction

