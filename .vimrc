set encoding=utf-8

"=====[ Enable italics in MacOS Terminal ]=======================

let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

"=====[ Avoid modeline vulnerability ]===========================

set nomodeline

"=====[ Not a fan of mapleader mappings ]===========================

let mapleader = '_'

"=====[ Reduce HETC requests ]===========================

set shm=at

"=====[ Convert to Unicode defaults ]===============================

setglobal termencoding=utf-8 fileencodings=
scriptencoding utf-8
set encoding=utf-8

autocmd BufNewFile,BufRead  *   try
autocmd BufNewFile,BufRead  *       set encoding=utf-8
autocmd BufNewFile,BufRead  *   endtry


"====[ Ensure autodoc'd plugins are supported ]===========

runtime plugin/_autodoc.vim


"====[ Work out what kind of file this is ]========

filetype plugin indent on

augroup FiletypeInference
    autocmd!
    autocmd BufNewFile,BufRead  *.t      setfiletype perl
    autocmd BufNewFile,BufRead  *.pod    setfiletype pod
    autocmd BufNewFile,BufRead  *.itn    setfiletype itn
    autocmd BufNewFile,BufRead  *        call s:infer_filetype()
augroup END

function! s:infer_filetype ()
    for line in getline(1,20)
        if line =~ '^\s*use\s*v\?5\.\S\+\s*;\s*$'
            setfiletype perl
            return
        elseif line =~ '^\s*use\s*v\?6\s*;\s*$'
            setfiletype raku
            return
        elseif line =~ '^\s*use\s*v\?\%([7-9]|\d\{2,}\)\s*;\s*$'
            setfiletype perl
            call Stop_ALE()
            return
        endif
    endfor
endfunction


"=====[ Comments are important ]==================

highlight Comment term=bold cterm=italic ctermfg=white gui=italic guifg=white

"Star-space or dash-space is a bullet
set comments=fb:*,fb:-


"=====[ Enable Nmap command for documented mappings ]================

runtime plugin/documap.vim


"====[ Edit and auto-update this config file and plugins ]==========

augroup VimReload
autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

Nmap <silent>  ;v   [Edit .vimrc]          :next $MYVIMRC<CR>
Nmap           ;vv  [Edit .vim/plugin/...] :next ~/.vim/plugin/


"====[ Edit my temporary working files ]====================

"Nmap tt  [Edit temporary files] :next ~/tmp/temporary_file



"=====[ Edit files in local bin directory ]========

Nmap ;b  [Edit ~/bin/...]  :next ~/bin/


"=====[ Some of Vim's defaults are just annoying ]============

" :read and :write shouldn't set #
set cpo-=aA

" Make /g the default on :s/.../../ commands (use /gg to disable)
"set gdefault

" Join lines with a single space only (even after sentence terminators)
set nojoinspaces



"=====[ Make diffs better ]=====================

" Prefer vertical orientation when using :diffsplit
set diffopt+=vertical

" No | in the vertical separator
set fillchars=vert:\ ,fold:-

" Use a smarter diff, if available...
if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=vertical,filler,internal,algorithm:histogram,indent-heuristic
endif

"====[ Go back to alternate file (but retain other g<whatever> mappings)]====

nmap g  :w<CR>:e #<CR><CR>

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


"====[ Toggle visibility of naughty characters ]============

" Make naughty characters visible...
set lcs=tab:══»,trail:␣,nbsp:˷
"   Tabs	shown	thusly	and	so
"   Trailing whitespace    
"   Non-breaking space

highlight InvisibleSpaces ctermfg=Black ctermbg=Black
call matchadd('InvisibleSpaces', '\S\@<=\s\+\%#\ze\s*$')


augroup VisibleNaughtiness
    autocmd!
    autocmd BufEnter  *       set list
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
highlight       Search    ctermfg=White  ctermbg=Black  cterm=bold
highlight    IncSearch    ctermfg=White  ctermbg=Red    cterm=bold

" Absolute direction for n and N...
nnoremap  <silent><expr> n  'Nn'[v:searchforward] . ":call HLNext()\<CR>"
nnoremap  <silent><expr> N  'nN'[v:searchforward] . ":call HLNext()\<CR>"

"Delete in normal mode to switch off highlighting till next search and clear messages...
Nmap <silent> <BS> [Cancel highlighting]  :call HLNextOff() <BAR> :nohlsearch <BAR> :call VG_Show_CursorColumn('off')<CR>

"Double-delete to remove trailing whitespace...
Nmap <silent> <BS><BS>  [Remove trailing whitespace] mz:call TrimTrailingWS()<CR>`z

function! TrimTrailingWS ()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction



"====[ Set background hint (if possible) ]=============

"if $VIMBACKGROUND != ""
"    exec 'set background=' . $VIMBACKGROUND
"else
"    set background=dark
"endif

set background=dark



"=====[ Enable smartwrapping ]==================================

" No smartwrapping in any of these files...
"let g:SW_IGNORE_FILES = '.vimrc,*.vim,*.pl,*.pm,**/bin/**'

set wrapmargin=2                            "Wrap 2 characters from the edge of the window
"set cinwords = ""                           "But not for C-like keywords
set cinoptions+=#1
set cinkeys-=0#

"=======[ Select formatting options explicitly ]=========================

set formatoptions=tnbl1jcro

" t : Auto-wrap text using textwidth.
" n : When formatting text, recognize numbered lists.
" b : Only auto-wrap if you enter a blank at or before the wrap margin.
" l : Already long lines are not broken in insert mode.
" 1 : Don't break a line after a one-letter word.
" j : Remove a comment leader when joining lines.
" c : Auto-wrap comments using textwidth, inserting the current comment leader automatically.
" r : Automatically insert the current comment leader after hitting <Enter> in Insert mode.
" o : Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.

function! BufSetFOA ()
"    if empty(&filetype) || &filetype == 'text'
"        set formatoptions+=a
"        set textwidth=79
"    endif
endfunction

" Turn on autoreformating of paragraphs in text files...
augroup Autoreindent
    autocmd!
    autocmd BufReadPost   *      call BufSetFOA()
augroup END


"=======[ Indentation ]============

set autoindent                     "Retain indentation on next line
filetype plugin indent on



"====[ I hate modelines ]===================

set modelines=0


"=====[ Quicker access to Ex commands ]==================

nmap ; :
xmap ; :


"=====[ Make Visual modes work better ]==================

" Visual Block mode is far more useful that Visual mode (so swap the commands)...
nnoremap v <C-V>
nnoremap <C-V> v

xnoremap v <C-V>
xnoremap <C-V> v

"Square up visual selections...
set virtualedit=block

" Make BS/DEL work as expected in visual modes (i.e. delete the selected text)...
xmap <BS> x

" Make vaa select the entire file...
xmap aa VGo1G

" Make q extend to the surrounding string...
xmap  q   "_y:call ExtendVisualString()<CR>

let s:closematch = [ '', '', '}', ']', ')', '>', '/', "'", '"', '`' ]
let s:ldelim = '\< \%(q [qwrx]\= \| [smy] \| tr \) \s*
\               \%(
\                   \({\) \| \(\[\) \| \((\) \| \(<\) \| \(/\)
\               \)
\               \|
\                   \(''\) \| \("\) \| \(`\)
\'
let s:ldelim = substitute(s:ldelim, '\s\+', '', 'g')

function! ExtendVisualString ()
    let [lline, lcol, lmatch] = searchpos(s:ldelim, 'bWp')
    if lline == 0
        return
    endif
    let rdelim = s:closematch[lmatch]
    normal `>
    let rmatch = searchpos(rdelim, 'W')
    normal! v
    call cursor(lline, lcol)
endfunction


"=====[ Make arrow keys move visual blocks around ]======================

xmap <silent> <UP>    <Plug>SchleppUp
xmap <silent> <DOWN>  <Plug>SchleppDown
xmap <silent> <S-UP>    <Plug>SchleppIndentUp
xmap <silent> <S-DOWN>  <Plug>SchleppIndentDown
xmap <silent> <LEFT>  <Plug>SchleppLeft
xmap <silent> <RIGHT> <Plug>SchleppRight

xmap <silent> D       <Plug>SchleppDupLeft
xmap <silent> <C-D>   <Plug>SchleppDupLeft


"=====[ Demo vim commands ]==============================

highlight WHITE_ON_BLACK ctermfg=white

Nmap     <silent> ;; [Demonstrate Vimscript block] :call DemoCommand()<CR>
xnoremap <silent> ;; :<C-U>call DemoCommand(1)<CR>

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




"=====[ Configure % key (via matchit plugin) ]==============================

" Match angle brackets...
set matchpairs+=<:>,«:»,｢:｣

"=====[ Miscellaneous features (mainly options) ]=====================

set title           "Show filename in titlebar of window
set titleold=
"set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set title titlestring=

set nomore          "Don't page long listings

set cpoptions-=a    "Don't set # after a :read

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

set wildignorecase                  "Case-insensitive completions

set wildmode=list:longest,full      "Show list of completions
                                    "  and complete as much as possible,
                                    "  then iterate full completions

set complete-=t                     " I don't use tags, so no need to search for them

set infercase                       "Adjust completions to match case

set noshowmode                      "Suppress mode change messages

set updatecount=10                  "Save buffer every 10 chars typed


" Keycodes and maps timeout in 3/10 sec...
set timeout timeoutlen=300 ttimeoutlen=300

" "idleness" is 0.5 sec
set updatetime=500

set thesaurus+=~/Documents/thesaurus    "Add thesaurus file for ^X^T
set dictionary+=~/Documents/dictionary  "Add dictionary file for ^X^K


set scrolloff=2                     "Scroll when 3 lines from top/bottom



"====[ Simplify textfile backups ]============================================

" Back up the current file
Nmap BB [Back up current file]  :!bak -q %<CR><CR>:echomsg "Backed up" expand('%')<CR>


"=====[ Remap various keys to something more useful ]========================

" Use space to jump down a page (like browsers do)...
nnoremap   <Space> <PageDown>
xnoremap   <Space> <PageDown>

" Install current file and swap to alternate file...
Nmap IP [Install current file and swap to alternate] :!install -f %<CR>


" Add *** as **/* on command-line...
cmap *** **/*

" Shift-Tab in visual mode to number lines...
xnoremap <S-TAB> :s/\%V/0<C-V><TAB>/<CR>gvg<C-A>gv:retab<ESC>gvI<C-G>u<ESC>gv/ <CR>:s/\%V /./<CR>

" Take off and nuke the entire buffer contents from space
" (It's the only way to be sure)...
nnoremap <expr> XX ClearBuffer()

function! ClearBuffer ()
    if &filetype =~ 'perl\|raku'
        return "1Gj}dGA\<CR>\<CR>\<ESC>"
    else
        return '1GdG'
    endif
endfunction

" Replace the current buffer with a copy of the most recent file...

nmap RR 1GdG:0r#<CR><C-G>

" Insert cut marks...
nmap -- A<CR><CR><CR><ESC>k6i-----cut-----<ESC><CR>


" Indent/outdent current block...
nmap %% $>i}``
nmap $$ $<i}``


" =====[ Perl programming support ]===========================

augroup PerlIndentedSchlepp
    autocmd!
    autocmd Filetype  perl   let b:Schlepp_reindent = 1
augroup END

augroup PerlKeywordChars
    autocmd!
    autocmd Filetype perl    setlocal iskeyword=@,48-57,_,192-255,$,%,@-@,:,#
    autocmd Filetype raku    setlocal iskeyword=@,48-57,_,192-255,$,%,@-@,:,-
augroup END

augroup PerlSignColumn
    autocmd!
    autocmd Filetype *       setlocal signcolumn=no
    autocmd Filetype perl    setlocal signcolumn=yes
augroup END

" Execute Perl file...
nmap <silent> W  :!clear;echo;echo;(script -q ~/tmp/script_$$ motleyperl %; if (-s ~/tmp/script_$$) then; alert; echo; echo; echo; getraw; endif; rm -f ~/tmp/script_$$ )<CR><CR>

" Execute Perl file (output to pager)...
nmap E :!motleyperl -m %<CR>

augroup PerlTestFile
    autocmd!
    autocmd BufEnter  *.t   nmap <silent><buffer>  W  :!clear;echo;echo;(script -q ~/tmp/script_$$ polyperl %; if (-s ~/tmp/script_$$) then; alert; echo; echo; echo; getraw; endif; rm -f ~/tmp/script_$$ )<CR><CR>
    autocmd BufEnter  *.t   nmap <silent><buffer> E  :!polyperl -m %<CR>
augroup END

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


" Insert common Perl code structures...

iab udx use Data::Dx; Dx
nmap dx A<CR>use Data::Dx; Dx;<LEFT>
iab udd use Data::Dump 'ddx'; ddx
iab uds use Data::Show; show
iab urd use Regexp::Debugger;
iab udv use Dumpvalue;<CR>Dumpvalue->new->dumpValues();<ESC>hi
iab uds use Data::Show;<CR>show
iab ubm use Benchmark qw( cmpthese );<CR><CR>cmpthese -10, {<CR>};<ESC>O
iab usc use Smart::Comments;<CR>###
iab uts use Test::Simple 'no_plan';
iab utm use Test::More 'no_plan';
iab dbs { no warnings 'once'; $DB::single = 1; }<ESC>


"=====[ Emphasize typical mistakes in Vim and Perl files ]=========

" Add a new high-visibility highlight combination...
highlight WHITE_ON_RED    ctermfg=White  ctermbg=Red  cterm=bold

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

let g:Mistakes = {
\    'vim'  : g:VimMistakes,
\}

let g:MistakesID = 668
augroup Mistakes
    autocmd!
    autocmd BufEnter  *.vim,*.vimrc   call s:Mistakes_AddMatch()
    autocmd BufLeave  *.vim,*.vimrc   call s:Mistakes_ClearMatch()
augroup END

function! s:Mistakes_AddMatch () abort
    call s:Mistakes_ClearMatch()
    try | call matchadd('WHITE_ON_RED',g:Mistakes[&filetype],10,g:MistakesID) | catch | endtry
endfunction

function! s:Mistakes_ClearMatch () abort
    for next_match in getmatches()
        if next_match['id'] == g:MistakesID
            try | silent call matchdelete(g:MistakesID) | catch | redraw | endtry
            break
        endif
    endfor
endfunction


"=====[ Call :make and then perltests from within a Perl buffer ]========

let &errorformat .= ",%f:%l %tarning:%m,%f:%l:%m"

set makeprg=polyperl\ -vc\ %\ $*

function! RunPerlTests ()
    if !empty(filter(getqflist(),{idx, val -> get(val,'type',"") == ''}))
        echohl WarningMsg
        echo "Errors detected, so won't run tests."
        echohl NONE
        silent cc 1
        return
    endif

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

"autocmd BufEnter *.p[lm],*.t  call SetupPerlTesting()
"function! SetupPerlTesting ()
"endfunction

autocmd BufEnter *.p[lm],*.t          let g:PerlTests_program = 'perltests'
autocmd BufEnter *.pm6,*.p6,*.raku*   let g:PerlTests_program = 'prove6'

let g:PerlTests_search_height = 5             " ...How far up the file hierarchy to search
let g:PerlTests_test_dir      = '/t'          " ...Where to look for tests

augroup PerlMake
    autocmd!

    autocmd BufReadPost quickfix  setlocal number
                             \ |  setlocal nowrap
                             \ |  setlocal modifiable
                             \ |  silent! %s/^[^|]*\//.../
                             \ |  setlocal nomodifiable
augroup END

Nmap <silent> ;t [Test this code] :call RunPerlTests()<CR>


"=====[ Placeholder data for templates (for the file_templates.vim plugin) ]=====

let g:FileTemplatesInfo = {
\   'AUTH'   : 'cpan:DCONWAY',
\   'AUTHOR' : 'Damian Conway',
\   'EMAIL'  : 'DCONWAY@cpan.org',
\}


"=====[ Proper syntax highlighting for Rakudo files ]===========

autocmd BufNewFile,BufRead  *   :call CheckForRaku()

function! CheckForRaku ()
    if getline(1) =~ 'rakudo'
        setfiletype raku
    endif
    if expand('<afile>:e') =~ 'rakudoc\|rakutest'
        setfiletype rakutest
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
call SmartcomAdd( '<<',    ANYTHING,  "\<BS>\<BS>«"                                    )
call SmartcomAdd( '>>',    ANYTHING,  "\<BS>\<BS>»"                                    )
call SmartcomAdd( '?',     ANYTHING,  '?',                               {'restore':1} )
call SmartcomAdd( '?',     '?',       "\<CR>\<ESC>O\<TAB>"                             )
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
    return "\<ESC>:call EQAS_Align('nmap',{'pattern':'" . a:pat . "'})\<CR>A"
endfunction
                " Left         Right        Insert
                " ==========   =====        =============================
call SmartcomAdd( '=',         ANYTHING,    "\<ESC>:call EQAS_Align('nmap')\<CR>A")
call SmartcomAdd( '=>',        ANYTHING,    AlignOnPat('=>') )
call SmartcomAdd( '\s#',       ANYTHING,    AlignOnPat('\%(\S\s*\)\@<= #') )
call SmartcomAdd( '[''"]\s*:', ANYTHING,    AlignOnPat(':'),                   {'filetype':'vim'} )
call SmartcomAdd( ':',         ANYTHING,    "\<TAB>",                          {'filetype':'vim'} )


                " Left         Right   Insert                                  Where
                " ==========   =====   =============================           ===================
" Vim keywords...
call SmartcomAdd( '^\s*func\%[tion]',
\                              EOL,    "\<C-W>function!\<CR>endfunction\<UP> ", {'filetype':'vim'} )
call SmartcomAdd( '^\s*for',   EOL,    " … in …\n…\n\<C-D>endfor\n…",           {'filetype':'vim'} )
call SmartcomAdd( '^\s*if',    EOL,    " … \n…\n\<C-D>endif\n…",                {'filetype':'vim'} )
call SmartcomAdd( '^\s*while', EOL,    " … \n…\n\<C-D>endwhile\n…",             {'filetype':'vim'} )
call SmartcomAdd( '^\s*try',   EOL,    "\n\t…\n\<C-D>catch\n\t…\n\<C-D>endtry\n…", {'filetype':'vim'} )

                " Left         Right   Insert                                  Where
                " ==========   =====   =============================           ===================
" Perl keywords...
call SmartcomAdd( '^\s*for',   EOL,    " my $… (…) {\n…\n}\n…", {' filetype':'perl'} )
call SmartcomAdd( '^\s*if',    EOL,    " (…) {\n…\n}\n…",       {' filetype':'perl'} )
call SmartcomAdd( '^\s*while', EOL,    " (…) {\n…\n}\n…",       {' filetype':'perl'} )
call SmartcomAdd( '^\s*given', EOL,    " (…) {\n…\n}\n…",       {' filetype':'perl'} )
call SmartcomAdd( '^\s*when',  EOL,    " (…) {\n…\n}\n…",       {' filetype':'perl'} )
call SmartcomAdd( '^\s*sub',   EOL,    " … (…) {\n…\n}\n…",     {' filetype':'perl'} )

" Complete Perl module loads with the names of Perl modules...
call SmartcomAddAction( '^\s*use\s\+\k\+', "",
\                       'set complete=k~/.vim/perlmodules|setlocal iskeyword+=:'
\)

" .itn itinerary files...
let s:flight_template = "\t…\nOn: \t…\nFrom:\t…\nTo: \t…\nDepart:\t…\nDTerm:\t…\nArrive:\t…\nATerm:\t…\nLength:\t…\nClass:\t…\nSeat:\t…\nBRef:\t…\nTrans:\t…\n"
let s:hotel_template = "\t…\nAddr:\t…\nPhone:\t…\nZone:\t…\nRate:\t…\nConfNo:\t…\n\nName:\t…\nEmail:\t…\nPhone:\t…\n"
let s:event_template = "\t…\nTime:\t…\nVenue:\t…\n"

                " Left             Right  Insert                  Where
                " ==========       =====  =====================   ===================

call SmartcomAdd( '^\s*Date:',     EOL,   "\t…\nSumm:\t…\n",      {'filetype':'itn'} )

call SmartcomAdd( '^\s*Flight:',   EOL,   s:flight_template,      {'filetype':'itn'} )
call SmartcomAdd( '^\s*Bus:',      EOL,   s:flight_template,      {'filetype':'itn'} )
call SmartcomAdd( '^\s*Train:',    EOL,   s:flight_template,      {'filetype':'itn'} )

call SmartcomAdd( '^\s*Hotel:',    EOL,   s:hotel_template,       {'filetype':'itn'} )

call SmartcomAdd( '^\s*Event:',    EOL ,  s:event_template,       {'filetype':'itn'} )
call SmartcomAdd( '^\s*Keynote:',  EOL ,  s:event_template,       {'filetype':'itn'} )
call SmartcomAdd( '^\s*Talk:',     EOL ,  s:event_template,       {'filetype':'itn'} )
call SmartcomAdd( '^\s*Course:',   EOL ,  s:event_template,       {'filetype':'itn'} )



"=====[ Itinerary generation ]===========

autocmd BufNewFile,BufRead  *.itn  nnoremap zd !!gen_itinerary_dates<CR>


"=====[ Miscellaneous completions ]============

call SmartcomAdd( 'Frederic',  ANYTHING,  "\<ESC>c?F\<CR>Frédéri\<RIGHT>", {} )


"=====[ General programming support ]===================================

" Insert various shebang lines...
iab hbc #! /bin/csh
iab hbs #! /bin/sh
iab hbp #! /usr/bin/env polyperl<CR>use 5.020;<CR>use warnings;<CR>use experimentals;<CR>
iab hbr #! /usr/bin/env raku<CR>use v6;


" Execute current file polymorphically...
Nmap ,, [Execute current file] :w<CR>:!clear;echo;echo;run %<CR>
Nmap ,,, [Debug current file]  :w<CR>:!clear;echo;echo;run -d %<CR>


"=====[ Show help files in a new tab, plus add a shortcut for helpg ]==============

let g:help_in_tabs = 1

"nmap <silent> H  :let g:help_in_tabs = !g:help_in_tabs<CR>

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


"=====[ Cut and paste from the system clipboard ]====================

" When in Normal mode, paste over the current line...
nmap  <C-P> 0d$"+p

" When in Visual mode, paste over the selected region...
xmap  <C-P> "+pgv

" In Normal mode, yank the entire buffer...
nmap <C-C> 1G"+yG``:call YankedToClipboard()<CR>

" In Visual mode, yank the selection...
xmap  <C-C> "+y:call YankedToClipboard()<CR>
xmap  <C-Y> "+y:call YankedToClipboard()<CR>

function! YankedToClipboard ()
    let block_of = (visualmode() == "\<C-V>" ? 'block of ' : '')
    let N = strlen(substitute(@*, '[^\n]\|\n$', '', 'g')) + 1
    let lines = (N == 1 ? 'line' : 'lines')
    redraw
    echo block_of . N lines 'yanked to clipboard'
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
    \   '^=\k*', "", 'set complete=k~/.vim/VimPointKeywords|setlocal iskeyword+=='
    \)
endfunction


" "=====[ Grammar checking ]========================================

highlight GRAMMARIAN_ERRORS_MSG   ctermfg=red   cterm=bold
highlight GRAMMARIAN_CAUTIONS_MSG ctermfg=white cterm=bold


"=====[ Highlight cursor ]===================

" Inverse highlighting for cursor...
highlight CursorInverse ctermfg=black ctermbg=white

" Set up highlighter at high priority (i.e. 99)
call matchadd('CursorInverse', '\%#.', 99)

" Need an invisible cursor column to make it update on every cursor move...
" (via the visualguide.vim plugin, so as to play nice)
runtime plugin/visualsmartia.vim
call VG_Show_CursorColumn('off')


"=====[ Highlight row and column on request ]===================

" Toggle cursor row highlighting on request...
highlight CursorLine   term=bold ctermbg=darkgrey ctermfg=yellow  cterm=bold
Nmap <silent> ;c [Toggle cursor line highlighting] :set cursorline!<CR>

" Toggle cursor column highlighting on request...
" (via visualguide.vim plugin, so as to play nice)
nmap     <silent> \  :silent call VG_Show_CursorColumn('flip')<CR>
xnoremap <silent> \  :<C-W>silent call VG_Show_CursorColumn('flip')<CR>gv
imap     <silent> <C-\>  <C-O>:silent call VG_Show_CursorColumn('flip')<CR>


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
"xnoremap  q :call Uniq()<CR>
"xnoremap  Q :call Uniq('ignore whitespace')<CR>


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
    autocmd BufEnter *.lei  nmap <buffer>  =  vip!sort -bdfu<CR>vip:call LEI_format()<CR><CR>
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

" Toggle special folds on and off...
nmap <silent> <expr>  zz  FS_ToggleFoldAroundSearch({'context':1})
nmap <silent> <expr>  zc  FS_ToggleFoldAroundSearch({'hud':1})


" Heads-up on function names (in Vim and Perl)...

let g:HUD_search = {
\   'vim':  { 'list':     [ { 'start': '^\s*fu\%[nction]\>!\?\s*\w\+.*',
\                             'end':   '^\s*endf\%[unction]\>\zs',
\                           },
\                           { 'start': '^\s*aug\%[roup]\>!\?\s*\%(END\>\)\@!\w\+.*',
\                             'end':   '^\s*aug\%[roup]\s\+END\>\zs',
\                           },
\                         ],
\              'default': '"file " . expand("%:~:.")',
\           },
\
\   'perl': { 'list':    [ { 'start': '\_^\s*\zssub\s\+\w\+.\{-}\ze\s*{\|^__\%(DATA\|END\)__$',
\                            'end':   '}\zs',
\                          },
\                          { 'start': '\_^\s*\zspackage\s\+\w\+.\{-}\ze\s*{',
\                            'end':   '}\zs',
\                          },
\                          { 'start': '\_^\s*\zspackage\s\+\w\+.\{-}\ze\s*;',
\                            'end':   '\%$',
\                          },
\                        ],
\             'default': '"package main"',
\          },
\ }

function! HUD ()
    let target = get(g:HUD_search, &filetype, {})
    let name = "'????'"
    if !empty(target)
        let name = eval(target.default)
        for nexttarget in target.list
            let [linestart, colstart] = searchpairpos(nexttarget.start, '', nexttarget.end, 'cbnW')
            if linestart
                let name = matchstr(getline(linestart), nexttarget.start)
                break
            endif
        endfor
    endif

    if line('.') <= b:FS_DATA.context
        return '⎺⎺⎺⎺⎺\ ' . name . ' /⎺⎺⎺⎺⎺' . repeat('⎺',200)
    else
        return '⎽⎽⎽⎽⎽/ ' . name . ' \⎽⎽⎽⎽⎽' . repeat('⎽',200)
    endif
endfunction

nmap <silent> <expr>  zh  FS_ToggleFoldAroundSearch({'hud':1, 'folds':'HUD()', 'context':3})


" Show only sub defns (and maybe comments)...
let perl_sub_pat = '^\s*\%(sub\|func\|method\|package\)\s\+\k\+'
let vim_sub_pat  = '^\s*fu\%[nction!]\s\+\k\+'
augroup FoldSub
    autocmd!
    autocmd BufEnter * nmap <silent> <expr>  zp  FS_FoldAroundTarget(perl_sub_pat,{'context':1})
    autocmd BufEnter * nmap <silent> <expr>  za  FS_FoldAroundTarget(perl_sub_pat.'\zs\\|^\s*#.*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  zp  FS_FoldAroundTarget(vim_sub_pat,{'context':1})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  za  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter * nmap <silent> <expr>             zv  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
augroup END

" Show only 'use' statements
nmap <silent> <expr>  zu  FS_FoldAroundTarget('\(^\s*\(use\\|no\)\s\+\S.*;\\|\<require\>\s\+\S\+\)',{'context':1})


"====[ Do a command, then restore the cursor ]======

command! -nargs=+ -complete=command Static  call Static_impl(<q-args>)

function! Static_impl (cmd)
    exec a:cmd
    normal ``
endfunction



"====[ Accelerated up and down on wrapped lines, but counted motions use actual lines ]============

nmap <expr> j  v:count ? 'j' : '<Plug>(accelerated_jk_gj)'
nmap <expr> k  v:count ? 'k' : '<Plug>(accelerated_jk_gk)'


"====[ Pathogen support ]======================

call pathogen#infect()
call pathogen#helptags()


"====[ Mapping to analyse a list of numbers ]====================

" Need to load this early, so we can override its nmapped ++
runtime plugin/eqalignsimple.vim

xnoremap <expr> ++  VMATH_YankAndAnalyse()
nmap            ++  vip++



"====[ Make digraphs easier to get right (various versions) ]=================

inoremap <expr>  <C-K>       BDG_GetDigraph()
"inoremap <expr>  <C-J>       HUDG_GetDigraph()
"inoremap <expr>  <C-L>       HUDigraphs()

function! HUDigraphs ()
    digraphs
    call getchar()
    return "\<C-K>"
endfunction


"====[ Extend a previous match ]=====================================

nnoremap //   /<C-R>/
nnoremap ///  /<C-R>/\<BAR>



"====[ Toggle between lists and bulleted lists ]======================

Nmap     <silent> ;l [Toggle list format (bullets <-> commas)]  :call ListTrans_toggle_format()<CR>f
xnoremap <silent> ;l                                            :call ListTrans_toggle_format('visual')<CR>f


"=====[ Select a table column in visual mode ]========================

xnoremap <silent><expr> c  VTC_select()


"=====[ Make * respect smartcase and also set @/ (to enable 'n' and 'N') ]======

nmap *  :let @/ = '\<'.expand('<cword>').'\>' ==? @/ ? @/ : '\<'.expand('<cword>').'\>'<CR>n


"=====[ Much smarter "edit next file" command ]=======================

        nmap <silent><expr>          e  g:GTF_goto_file()
silent! nmap <unique><silent><expr>  q  g:GTF_goto_file('`')




"=====[ Smarter interstitial completions of identifiers ]=============
"
" When autocompleting within an identifier, prevent duplications...

augroup Undouble_Completions
    autocmd!
    autocmd CompleteDone *  call Undouble_Completions()
augroup END

function! Undouble_Completions ()
    let col  = getpos('.')[2]
    let line = getline('.')
    call setline('.', substitute(line, '\(\.\?\k\+\)\%'.col.'c\zs\1\>', '', ''))
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


"=====[ Improve ruler with various useful information]=================================

let g:BRF_new_rulerformat = '%40(%#NonText# %v⇢ %l⇣ %{BRF_CharCount()}| %= %{BRF_ErrStatus()}  %<%{BRF_WordCount()} %L⤓  %P%)'

function! BRF_CharCount()
    return get(wordcount(),'cursor_chars','???')
endfunction

function! BRF_ErrStatus()
    " Count errors and warnings in quickfix list...
    let [errors, warnings] = [0,0]
    for type in map(getqflist(), {key, val -> get(val, "type", "?")})
        if     type == "" || type == 'e'  |  let errors   += 1
        elseif               type == 'w'  |  let warnings += 1
        endif
    endfor

    " Count matches and distinct files in location list...
    let loclist  = getloclist(0)
    let matches  = len(loclist)
    let files    = {}
    for locelem in loclist
        let files[locelem.bufnr] = 1
    endfor
    let buffers  = len(files)

    " Generate report for ruler...
    let status = []
    if errors   | call add(status, errors   . 'ꜝ') | endif
    if warnings | call add(status, warnings . 'ʷ') | endif
    if matches  | call add(status, matches  . 'ᵐ ' . buffers . 'ᵇ') | endif

    return join(status, ' ')
endfunction

let g:BRF_interval = 1
function! BRF_WordCount()

    " Skip an increasing percentage of increasingly expensive updates, as the file gets longer...
    let g:BRF_interval += 1
    if exists("b:BRF_wordcount")
        let timestamp = get(b:,'BRF_timestamp', -1)
        if g:BRF_interval < b:BRF_wordcount / 500
            return b:BRF_wordcount . (timestamp == undotree().seq_cur ? '⁞' : '⁞̃' )
        endif
        let g:BRF_interval = 1
    endif

    " Otherwise, recount the file...
    if &modified || !exists("b:BRF_wordcount")
        let lines = join(getline(1,'$'), ' ')
        let lines = substitute(lines, '\d\.\d',         'X', 'g')
        let lines = substitute(lines, '\a[''-]\a',      'X', 'g')
        let lines = substitute(lines, '[[:alnum:]]\+',  'X', 'g')
        let lines = substitute(lines, '[^[:alnum:]]\+', '',  'g')
        let b:BRF_wordcount = strlen(lines)
        let b:BRF_timestamp = undotree().seq_cur
    endif

    " Return the precise count...
    return b:BRF_wordcount . '⁞'
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


"======[ Tweak highlighted yank plugin ]====================================

highlight HighlightedyankRegion cterm=NONE ctermfg=white ctermbg=brown

let g:highlightedyank_highlight_duration = -1

let g:highlightedyank_quench_when = [ ['CursorMoved', '<buffer>'] ]



"======[ Add a Y command for incremental yank in Visual mode ]==============

xnoremap <silent>       Y   <ESC>:silent let @y = @"<CR>gv"Yy:silent let @" = @y<CR>
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

xmap     <silent>       ]   <ESC>gv_$
xnoremap <silent><expr> _$  Under_dollar_visual()

function! Under_dollar_visual ()
    " Locate block being shifted...
    let maxcol = max(map(getline("'<","'>"), 'strdisplaywidth(v:val)'))

    " Return the selection that does the job...
    return maxcol . '|'
endfunction

"=====[ Diff against disk ]==========================================

map <silent> zd :silent call DC_DiffChanges()<CR>

" Change the fold marker to something more useful
function! DC_LineNumberOnly ()
    if v:foldstart == 1 && v:foldend == line('$')
        return '.. ' . v:foldend . '  (No difference)'
    else
        return '.. ' . v:foldend
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
    set diffopt=context:2,filler,foldcolumn:0
"    set fillchars=fold:ÃÂ 
    set foldcolumn=0
    setlocal foldtext=DC_LineNumberOnly()
    set number

"    aboveleft vnew
    belowright vnew
    normal 0
    silent call setline(1, initial_state)
    diffthis
    set diffopt=context:2,filler,foldcolumn:0
"    set fillchars=fold:ÃÂ 
    set foldcolumn=0
    setlocal foldtext=DC_LineNumberOnly()
    set number

    nmap <silent><buffer> zd :diffoff<CR>:q!<CR>:set diffopt& fillchars& number& foldcolumn=0<CR>:set nodiff<CR>:highlight Normal ctermfg=NONE<CR>
endfunction


"=====[ ,, as => without delays ]===================

inoremap <expr><silent>  ,  Smartcomma()

function! Smartcomma ()
    let [bufnum, lnum, col, off, curswant] = getcurpos()
    if getline('.') =~ (',\%' . (col+off) . 'c')
        return "\<C-H>=>"
    else
        return ','
    endif
endfunction


"=====[ Interface with ag ]======================

set grepprg=ag\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m

" Also use ag in GVI...
let g:GVI_use_ag = 1


"=====[ Decute startify ]================

let g:startify_custom_header = []


"=====[ Configure change-tracking ]========

let g:changes_hl_lines=1
let g:changes_verbose=0
let g:changes_autocmd=1


"=====[ Make netrw more instantly useful ]============

let g:netrw_sort_by        = 'time'
let g:netrw_sort_direction = 'reverse'
let g:netrw_banner         = 0
let g:netrw_liststyle      = 3
let g:netrw_browse_split   = 3
let g:netrw_fastbrowse     = 1
let g:netrw_sort_by        = 'name'
let g:netrw_sort_direction = 'normal'


"=====[ Rakudoc proofing ]==========

nmap <silent> ;p :silent call Rakudoc_ToggleProofing()<CR>:silent call WarmMargin('off')<CR><C-L>


"======[ Breakindenting ]========

set breakindentopt=shift:2,sbr
set showbreak=↪
set breakindent
set linebreak


"======[ Writing support ]=======

augroup PiRakudoc
autocmd!

    autocmd BufEnter *.rakudoc   iab P5 Perl 5

    autocmd BufEnter *.rakudoc   iab h1 =head1
    autocmd BufEnter *.rakudoc   iab h2 =head2
    autocmd BufEnter *.rakudoc   iab h3 =head3
    autocmd BufEnter *.rakudoc   iab h4 =head4
    autocmd BufEnter *.rakudoc   iab h5 =head5

    for L in split('C I B R')
        let l = tolower(L)
        exec 'autocmd BufEnter *.rakudoc   xnoremap <TAB>' . l . ' "vygvc' . L . '<C-R><C-R>=Rakudoc_delim("")<CR><ESC>'
        exec 'autocmd BufEnter *.rakudoc   nmap     <TAB>' . l . ' viw<TAB>' . l
    endfor

    autocmd BufEnter *.rakudoc   xnoremap <TAB>m  "vygvcM<C-R><C-R>=Rakudoc_delim('T:')<CR><ESC>
    autocmd BufEnter *.rakudoc   nmap     <TAB>m  viw<TAB>m

    function! Rakudoc_delim (prefix)
        let regy = getreg('v')
        if regy =~ '[<>]'
            return '«' . a:prefix . regy . '»'
        else
            return '<' . a:prefix . regy . '>'
        endif
    endfunction

    call SmartcomAdd(               '''',  '',    "\<BS>‘")
    call SmartcomAdd(             '[‘’]',  '',    "\<BS>'")
    call SmartcomAdd( '\(\w\|[‘.!?]\)''',  '',    "\<BS>’")
    call SmartcomAdd(                '"',  '',    "\<BS>“")
    call SmartcomAdd(  '\(\w\|[“.!?]\)"',  '',    "\<BS>”")
    call SmartcomAdd(     '\.\@<!\.\.\.',  '',    "\<BS>\<BS>\<BS>…")
    call SmartcomAdd(          '--',       '',    "\<BS>\<BS>—")
    call SmartcomAdd(          '_',        '',    "\<BS>␣")


augroup END


"=====[ Automate syntax highlighting ]===============================

" Keep long lines from slowing Vim too much
set synmaxcol=200

augroup Autosyntax_actions
    autocmd!
    autocmd FileType netrw  syntax on
    autocmd BufEnter   *    call AS_Enter()
    autocmd BufLeave   *    syntax off
augroup END

command! -complete=filetype -nargs=+ Autosyntax call AS_set_active(<q-args>)

let g:AS_active_in = {}

function! AS_set_active(list)
    for ft in split(a:list, '\s\+')
        let g:AS_active_in[ft] = 1
        let g:AS_active_in['.'.ft] = 1
    endfor
endfunction

Autosyntax itn
Autosyntax rakudoc
Autosyntax markdown
Autosyntax todo
Autosyntax diff patch

function! AS_Enter ()
    let suffix = '.' . expand('<afile>:e')
    if get(g:AS_active_in, &filetype, 0) || suffix != '.' && get(g:AS_active_in, suffix, 0)
        syntax enable
    endif
endfunction

nmap <silent> ;y   :call AS_toggle()<CR>

function! AS_toggle ()
    let suffix = '.' . expand('%:e')
    if exists('g:syntax_on')
        syntax off
        let g:AS_active_in[&filetype] = 0
        let g:AS_active_in[suffix]    = 0
    else
        syntax enable
        let g:AS_active_in[&filetype] = 1
        let g:AS_active_in[suffix]    = 1
    endif
endfunction


"=====[ Double quote Perl single quotes and vice versa ]==================

call SmartcomAdd(      '''[^"]*"',  NOTHING,  "\<ESC>?'\<CR>:nohlsearch\<CR>r\"a",        {'restore':1+1} )
call SmartcomAdd( 'q\@<!q{[^"]*"',  NOTHING,  "\<BS>}\<ESC>?q{\<CR>:nohlsearch\<CR>sqq",  {'restore':1+2} )
call SmartcomAdd(     '"[^'']*''',  NOTHING,  "\<ESC>?\"\<CR>:nohlsearch\<CR>r'a",        {'restore':1+1} )
call SmartcomAdd(   'qq{[^'']*''',  NOTHING,  "\<BS>}\<ESC>?qq{\<CR>:nohlsearch\<CR>2sq", {'restore':1+1} )

"=====[ Translate common currencies ]==================

call SmartcomAdd('\<EUR', NOTHING, "\<ESC>xxs€" )
call SmartcomAdd('\<GBP', NOTHING, "\<ESC>xxs£" )
call SmartcomAdd('\<ILS', NOTHING, "\<ESC>xxs₪" )
call SmartcomAdd('\<INR', NOTHING, "\<ESC>xxs₨" )
call SmartcomAdd('\<JPY', NOTHING, "\<ESC>xxs¥" )
call SmartcomAdd('\<YEN', NOTHING, "\<ESC>xxs¥" )

"=====[ Park cursor and demarginalize in vimpoint files ]========================

augroup VimpointConfig
    autocmd!
    autocmd  BufEnter  *.vp*   :normal 0
    autocmd  BufEnter  *.vp*   WarmMargin never
augroup END

"=====[ Let <UP> and <DOWN> iterate the quickfix buffer list too ]=========

let g:ArrNav_arglist_fallback = 1


"=====[ Blockwise mode on : in visual mode ]===============================

let g:Blockwise_autoselect = 1


"=====[ Make jump-selections work better in visual block mode ]=================

xnoremap <expr>  G   'G' . virtcol('.') . "\|"
xnoremap <expr>  }   '}' . virtcol('.') . "\|"
xnoremap <expr>  {   '{' . virtcol('.') . "\|"


"=====[ Bracketed paste mode ]=======================================

if &term =~ "xterm.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te

    function! XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction

    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
    xmap <expr> <Esc>[200~ XTermPasteBegin("c")

    cmap        <Esc>[200~ <nop>
    cmap        <Esc>[201~ <nop>
endif


"=====[ Configure ALE ]==================

highlight AleError    ctermfg=red     cterm=bold
highlight AleWarning  ctermfg=magenta cterm=bold

augroup ALE_Autoconfig
    au!
    " Just for the demo
    "    autocmd BufEnter *.pl   silent call Stop_ALE()

    autocmd BufEnter *      silent call Stop_ALE()
    autocmd BufEnter *.pl   silent call Start_ALE()

    autocmd User PV_Start   silent call Stop_ALE()
    autocmd User PV_End     silent call Start_ALE()
    autocmd User GVI_Start  echomsg 'AleDisable'
    autocmd User GVI_Start  silent ALEDisable
augroup END

hi ALEErrorLine     ctermfg=red  cterm=bold,italic
hi ALEWarningLine   ctermfg=red  cterm=bold,italic
hi ALEInfoLine      ctermfg=red
hi ALEError         ctermfg=red  cterm=bold,italic
hi ALEWarning       ctermfg=red  cterm=bold,italic
hi ALEInfo          ctermfg=red
hi ALEStyleError    ctermfg=red  cterm=bold,italic
hi ALEStyleWarning  ctermfg=red  cterm=bold,italic
hi ALEErrorSign     ctermfg=white   ctermbg=darkred  cterm=bold
hi ALEWarningSign   ctermfg=white   ctermbg=darkred  cterm=bold
hi ALEInfoSign      ctermfg=white   ctermbg=darkblue

hi ALESignColumnWithErrors      ctermfg=white   ctermbg=darkred
hi ALESignColumnWithoutErrors   ctermfg=white   ctermbg=22
hi SignColumn                   ctermfg=white   ctermbg=22

let g:ale_change_sign_column_color = 1
let g:ale_set_loclist              = 0
let g:ale_set_quickfix             = 1
let g:ale_set_signs                = 1
let g:ale_linters                  = { 'perl': ['perl'] }
let g:ale_perl_perl_executable     = 'polyperl'
let g:ale_perl_perl_options        = '-cw -Ilib'
let g:ale_lint_on_text_changed     = 'normal'
let g:ale_lint_on_insert_leave     = 1
let g:ale_set_highlights           = 1
let g:ale_lint_delay               = 0

let g:ale_sign_error = '🄴 '
let g:ale_sign_warning = '🇼 '
let g:ale_sign_info = '🇮 '
let g:ale_sign_style_error = '🅂 '
let g:ale_sign_style_warning = '🇸 '

Nmap <silent> ;m [Toggle automake on Perl files] :call Toggle_ALE()<CR>

function! Start_ALE ()
    if !expand('./.noale')
        ALEEnable
    endif
endfunction

function! Stop_ALE ()
    silent call s:ChangeProfile(&filetype)
    ALEDisable
    call setqflist([])
    redraw!
endfunction

function! Toggle_ALE ()
    if expand('./.noale')
        call Stop_ALE()
        echo 'Error highlighting disabled (.noale)'
    elseif g:ale_enabled
        call Stop_ALE()
        echo 'Error highlighting off'
    else
        call Start_ALE()
        echo 'Error highlighting on'
    endif
endfunction

"=====[ Adjust terminal profile for various cases ]=========

augroup AutoProfile
    au!
    autocmd User ALELintPost        call s:AutoChangeProfile()
    autocmd BufEnter *              call s:AutoChangeProfile()
    autocmd VimLeave *              call s:ChangeProfile('default')
augroup END

let s:Profile = {
\    'default'  : 'yellow',
\    'raku'     : 'blue',
\    'perl6'    : 'blue',
\    'haskell'  : 'futuristic',
\    'java'     : 'dubya',
\    'fortran'  : 'typewriter',
\    'markdown' : 'markdown',
\}

function! s:AutoChangeProfile ()
    sleep 1m
    call s:ChangeProfile(&filetype)
"    if &filetype == 'help' || empty(filter(getqflist(),{idx, val -> get(val,'bufnr',"") == bufnr('%')}))
"        call s:ChangeProfile(&filetype)
"    else
"        call s:ChangeProfileErrors(&filetype)
"    endif
endfunction

function! s:ChangeProfile (name)
    let bg = get(s:Profile, a:name, s:Profile['default'])
    silent exec "!terminal_profile '" . bg . "'"
endfunction

function! s:ChangeProfileErrors (name)
    let bg = get(s:Profile, a:name, s:Profile['default'])
    silent exec "!terminal_profile '" . bg . " errors'"
endfunction


"=====[ Select a completion from the menu without inserting a <CR> ]========

inoremap <expr> <CR> ((pumvisible())?("\<C-Y>"):("\<CR>"))


"=====[ Change cursor during insertion ]======================

let &t_SI="\033[5 q" " start insert mode, switch to blinking cursor
let &t_EI="\033[1 q" " end insert mode, back to square cursor


"=====[ Completion during search (via Command window) ]======================

function! s:search_mode_start()
    cnoremap <tab> <c-f>:resize 1<CR>a<c-n>
    let s:old_complete_opt = &completeopt
    let s:old_last_status = &laststatus
    set completeopt-=noinsert
    set laststatus=0
endfunction

function! s:search_mode_stop()
    try
        silent cunmap <tab>
    catch
    finally
        let &completeopt = s:old_complete_opt
        let &laststatus  = s:old_last_status
    endtry
endfunction

augroup SearchCompletions
    autocmd!
    autocmd CmdlineEnter [/\?] call <SID>search_mode_start()
    autocmd CmdlineLeave [/\?] call <SID>search_mode_stop()
augroup END


"=====[ Make multi-selection incremental search prettier ]======================

augroup SearchIncremental
    autocmd!
    autocmd CmdlineEnter [/\?:]   highlight  Search  ctermfg=Black ctermbg=DarkRed  cterm=NONE
    autocmd CmdlineLeave [/\?:]   highlight  Search  ctermfg=White  ctermbg=Black    cterm=bold
augroup END


"=====[ Configure table-mode ]=================================================

let g:table_mode_corner                 = '|'
let g:table_mode_corner_corner          = '|'
let g:table_mode_header_fillchar        = '='
let g:table_mode_fillchar               = '-'
let g:table_mode_align_char             = ':'
let g:table_mode_cell_text_object_a_map = 'ac'
let g:table_mode_cell_text_object_i_map = 'ic'
let g:table_mode_syntax                 = 1
let g:table_mode_delimiter              = ' \{2,}'

nmap <TAB> :TableModeToggle<CR>
xmap <TAB> <ESC><TAB>gv
xmap <silent> T :<C-U>call ToggleTabularization()<CR>

function! ToggleTabularization ()
    let range = getpos('''<')[1] .','. getpos('''>')[1]
    if getline("'<") =~ '\\\@!|'
        silent TableModeEnable
        exec 'silent! ' . range . 's/[-= ]\@<=+\|+[-= ]\@=/  /g'
        exec 'silent! ' . range . 's/[-= ]|[-= ]\|[^\\]\zs|[-= ]\|[-= ]|/  /g'
        exec 'silent! ' . range . 's/\s\+$//'
        nohlsearch
        TableModeDisable
    else
        TableModeEnable
        '<,'>Tableize
    endif
    normal gv
endfunction


"=====[ Make vim-dirvish work how I prefer ]============

" Sort directories first...
let g:dirvish_mode = ':sort ,^.*[\/],'

augroup DirvishConfig
    autocmd!
    autocmd FileType dirvish  :call MyDirvishSetup()
augroup END

function! MyDirvishSetup ()
    " Set up the mapping I want...
    nmap <buffer> .. <Plug>(dirvish_up)

    " Make directories stand out...
    syntax enable

    " Make current selection stand out...
    highlight CursorLine  cterm=bold ctermfg=white ctermbg=blue
    highlight MatchLine   cterm=bold ctermfg=white ctermbg=blue

    " Map <TAB> to open in new tab...
    nnoremap <silent><buffer> <TAB> :call DirvishX_TabOpen()<CR>
    xnoremap <silent><buffer> <TAB> :call DirvishX_TabOpen()<CR>

    " Map <CR> to :next the selected file(s) and then cycle back
    nnoremap <silent><buffer> <CR> :call DirvishX_Open()<CR>
    xnoremap <silent><buffer> <CR> :call DirvishX_Open()<CR>

    " Remove search pattern at start, and on <DELETE>...
    let @/ = ''
    nnoremap <silent><buffer> <BS> :call DirvishResetMatches()<CR>

    " Various other tricks...
    let dirvish_file = expand('<afile>')
    augroup DirvishConfig
        exec 'autocmd BufEnter    ' . dirvish_file . '  :normal R'
        exec 'autocmd CursorMoved ' . dirvish_file . '  :call DirvishUpdateMatches()'
    augroup END
endfunction

function! DirvishSmartMatch ()
    let ignorecase = &ignorecase              ? '\c' : ''
    let smartcase  = &smartcase && @/ =~ '\u' ? '\C' : ''
    return ignorecase . smartcase . '^.*'.@/.'.*'
endfunction

function! DirvishMatchedFiles ()
    let current_search_pattern = DirvishSmartMatch()
    let filelist = []
    for line in getline(1,'$')
        if line =~ current_search_pattern
            call add(filelist, line)
        endif
    endfor
    return filelist
endfunction

function! DirvishUpdateMatches ()
    if len(@/)
        silent! call matchdelete(b:dirvish_matchline)
        let b:dirvish_matchline = matchadd('MatchLine', DirvishSmartMatch())
        highlight CursorLine  cterm=bold ctermfg=white ctermbg=NONE
    else
        highlight CursorLine  cterm=bold ctermfg=white ctermbg=blue
    endif
endfunction

function! DirvishResetMatches ()
    nohlsearch
    let @/ = ''
    silent! call matchdelete(b:dirvish_matchline)
    highlight CursorLine  cterm=bold ctermfg=white ctermbg=blue
endfunction

function! DirvishX_Open () range
    let files = len(@/) ? DirvishMatchedFiles() : getline(a:firstline, a:lastline)
    exec ':next ' . join(files) . ' %'
endfunction

function! DirvishX_TabOpen () range
    let files = len(@/) ? DirvishMatchedFiles() : getline(a:firstline, a:lastline)
    for file in files
        exec ':tabedit ' . file
    endfor
    2tabnext
endfunction


"=======[ Prettier tabline ]============================================

highlight Tabline      cterm=underline       ctermfg=40     ctermbg=22
highlight TablineSel   cterm=underline,bold  ctermfg=white  ctermbg=28
highlight TablineFill  cterm=NONE            ctermfg=black  ctermbg=black


"=======[ Swap <C-A> and g<C-A>, improve <C-A>, and persist in visual mode ]============

xnoremap   <C-A>   g<C-A>gv<C-X>gv
xnoremap  g<C-A>    <C-A>gv


"=======[ Make literal spaces match any whitespace in searches ]============

cnoremap <C-M> <C-\>e('/?' =~ getcmdtype() ? substitute(getcmdline(), '\\\@<! ', '\\_s\\+', 'g') : getcmdline())<CR><CR>


"=======[ Limelight configuration ]==========================================

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'

" Default dimming: 0.5
let g:limelight_default_coefficient = 0.7

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1


"========[ "Find this again" in visual mode ]===========================

function! VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap n  :<C-u>call VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap N  :<C-u>call VSetSearch('?')<CR>?<C-R>=@/<CR><CR>


"========[ Markdown config ]=============================================

let g:markdown_syntax_conceal              = 1
let g:vim_markdown_strikethrough           = 1
let g:vim_markdown_emphasis_multiline      = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:markdown_minlines                    = 5000
let g:markdown_fenced_languages            = ['perl', 'raku']

augroup MarkdownConfig
    autocmd!
    autocmd Filetype markdown    setlocal conceallevel=2
    autocmd Filetype markdown    nmap <buffer><silent> f  !Gformat -T4 -95<CR>
    autocmd Filetype markdown    nmap <buffer><expr>   ff MD_break()
    autocmd Filetype markdown    nmap <buffer><expr>   ee MD_entity()
    autocmd Filetype markdown    imap <buffer><expr>   '  MD_educate("'")
    autocmd Filetype markdown    imap <buffer><expr>   "  MD_educate('"')
    autocmd Filetype markdown    xnoremap <buffer>     cc A</code><ESC>gvI<code><ESC>gv13l
    autocmd Filetype markdown    xnoremap <buffer>     ss A</strong><ESC>gvI<strong><ESC>gv17l
    autocmd Filetype markdown    xnoremap <buffer>     ee A</em><ESC>gvI<em><ESC>gv9l
    autocmd Filetype markdown    xnoremap <buffer>     bb A</sub><ESC>gvI<sub><ESC>gv11l
    autocmd Filetype markdown    xnoremap <buffer>     pp A</sup><ESC>gvI<sup><ESC>gv11l
    autocmd Filetype markdown    xnoremap <buffer>     tt A</tt><ESC>gvI<tt><ESC>gv9l
    autocmd Filetype markdown    xnoremap <buffer>     qq "qda<blockquote><em><CR></em></blockquote><CR><ESC>k"qP
augroup END

function! MD_entity ()
    let currline = getline('.')
    let cursor_char = strcharpart(currline[col('.') - 1:], 0, 1)
    if cursor_char =~ '&'
        return "s&amp;\<ESC>l"
    elseif cursor_char =~ '<'
        return "s&lt;\<ESC>l"
    elseif cursor_char =~ '>'
        return "s&gt;\<ESC>l"
    elseif cursor_char =~ '–'
        return "s&mdash;\<ESC>l"
    elseif cursor_char =~ '_'
        return "s&lowbar;\<ESC>l"
    elseif cursor_char =~ '*'
        return "s&ast;\<ESC>l"
    elseif cursor_char =~ ' '
        return "s&nbsp;\<ESC>l"
    endif
endfunction

function! MD_break ()
    " Special case at EOL
    if virtcol('.') + 1 == virtcol('$')
        return "a<br/>\<ESC>\<CR>m`V}:\<C-U>silent! '<,'>s/<br\\/>//g\<CR>``f"
    endif

    let currline = getline('.')
    let cursor_char = strcharpart(currline[col('.') - 1:], 0, 1)
    if cursor_char =~ '\s'
        return "s<br/>\<CR>\<ESC>m`V}:\<C-U>silent! '<,'>s/<br\\/>//g\<CR>``fgej"
    else
        return "?\\s\<CR>s<br/>\<CR>\<ESC>m`V}:\<C-U>silent! '<,'>s/<br\\/>//g\<CR>``fgej"
    endif
endfunction

function! MD_educate (quotechar)
    if getline('.') =~ '^\s\{0,3}\S\@=\([^`<]\+\|`[^`]*`\|<[^>]*>\)*\%' . col('.') . 'c'
        return a:quotechar . "\<TAB>"
    else
        return a:quotechar
    endif
endfunction


"=====[ Reduce "Press ENTER to continue" annoyances ]===============

set cmdheight=2



"=====[ Fix <C-A> in visual mode ]==========================

xnoremap <silent> <C-A> "sy:call Genseq()<CR>gv"sp

function! Genseq () abort
    echo 'Sequencing...'
    call setreg('s', system('genseq', @s), 'b')
    redraw
    echo
endfunction

"======[ Text::Autoformat integration ]=====================
"
" Format file with autoformat (capitalize to specify options)...
nmap                 F  !Gformat -T4 -
nmap  <silent><expr> f  TAformat()

function! TAformat ()
    let b:TAline = get(b:, 'TAline', 0)
    let curline  = line('.')
    if curline == b:TAline
        let endpara = search('^\s*$', 'cznW') - 1
        let lines   = getline(curline, endpara)
        let width   = max(map(lines, {_, val -> strchars(val)})) - 1
        return '!Gformat -T4 -' . width . "\<CR>"
    else
        let b:TAline  = curline
        return '!Gformat -T4' . "\<CR>"
    endif
endfunction


" Break line and reformat...
nmap          ff r<CR>fgej

" Likewise in visual selections...
xmap          F :!format -T4 -all -
xmap <silent> f :!format -T4 -all<CR>


"======[ macOS terminal is fast ]==================

set ttyfast


"======[ Defang <C-S> and <C-Q> inside Vim ]==================

silent !stty -ixon
autocmd VimLeave * silent !stty ixon


"======[ Jump to most recent file of type <W>hatever ]=====================================

augroup LastFileOfType
    autocmd!
    autocmd BufWritePost *.pl                       normal! mP
    autocmd BufWritePost *.pm                       normal! mM
    autocmd BufWritePost *.t                        normal! mT
    autocmd BufWritePost *.vim                      normal! mP
    autocmd BufWritePost vimrc                      normal! mV
augroup END

"=======[ Configure Bufferize plugin ]===================

let g:bufferize_command = 'tabnew'


"=======[ Configure perlart plugin ]===================

let g:loaded_perlart = 1
silent xnoremap <silent><buffer><expr>      <C-S>        PerlART_RefactorToSub('all')


"=======[ Configure traces plugin ]=====================

highlight TracesSearch   ctermfg=White  ctermbg=Red    cterm=bold
highlight TracesReplace  ctermfg=Black  ctermbg=Cyan   cterm=bold

nmap <expr> S  GlobalSearchSetup('nS')
xmap <expr> S  GlobalSearchSetup('xS')

nmap <expr> M  GlobalSearchSetup('nM')
xmap <expr> M  GlobalSearchSetup('xM')

"augroup GlobalSearch
"    autocmd CmdlineLeave *  set nogdefault
"augroup END

function! GlobalSearchSetup (mode)
"    set gdefault
    return a:mode == 'nS'  ?  ":%s/"
       \ : a:mode == 'xS'  ?  ":s/"
       \ : a:mode == 'nM'  ?  ':%s/' . @/
       \ : a:mode == 'nS'  ?  ':s/'  . @/
       \ :                    ""
endfunction


"###### COMMAND TO DISPLAY COLOURS ###############

function! ShowColours () abort
    for n in range(0,255)
        exec 'hi ColourDemo ctermfg='.n.' ctermbg='.n
        echon printf("%3d",n)
        echohl ColourDemo
        echon 'XXX'
        echohl NONE
        if (n+1) % 16 == 0
            echo ""
        endif
    endfor
endfunction

command! ShowColours call ShowColours()



