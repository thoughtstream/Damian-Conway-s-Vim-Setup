" Vim global plugin for tracking Perl vars in source
"
" Last change:  Sun May 18 11:40:10 EST 2014
" Maintainer:   Damian Conway
" License:  This file is placed in the public domain.
"
" trackperlvars.vim (TPV) provides two main features:
"
" 1.  When you place a cursor over a perl variable, TPV will
"     highlight the variable, and all other instances of that variable.
"
"     While highlighted; three functions are available:
"     1. "gd" or "goto definition" will bounce you to where the variable is defined.
"     2. "cv" or "change variable" will rename all found instances of the
"        variable, scope is either by visual selection, or globally.
"     3. "*" will search for the current variable.
"
" 2.  If you highlight a perl punctuation var ($_, @_ or $/ for example),
"     then you will get extra info telling you about its primary purpose.
"
" "tt" or "toggle tracking" will enable/disable TPV.

" If already loaded, we're done...
if exists("loaded_trackperlvars")
    finish
endif
let loaded_trackperlvars = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"=====[ Interface ]==========================================

" Track vars after each cursor movement...
augroup TrackVarGlobal
    autocmd!
    autocmd BufEnter *  call TPV__setup()
    autocmd WinEnter *  call TPV__setup()
    autocmd BufLeave *  call TPV__teardown()
augroup END

function! TPV__setup ()
    " Only in small Perl files...
    if &filetype == 'perl' || expand("%:e") =~ '^\%(\.p[lm]\|\.t\)$'

        " Tracking can be locked by setting this variable
        if !exists('b:track_perl_var_locked')
            let b:track_perl_var_locked = 0
        endif

        " Set up autocommands...
        augroup TrackVarBuffer
            autocmd!
            autocmd CursorMoved  <buffer>  call TPV_track_perl_var()
            autocmd CursorMovedI <buffer>  call TPV_track_perl_var()
        augroup END

        " Remember how * was set up (if it was) and change it...
        let b:old_star_map = maparg('*')
        nmap <special> <buffer><silent> *   :let @/ = TPV_locate_perl_var()<CR>

        " cv --> change variable...
        nmap <silent> <special> <buffer>         cv  :silent call TPV_rename_perl_var('normal')<CR>
        xmap <silent> <special> <buffer>         cv  :silent call TPV_rename_perl_var('visual')<CR>gv

        " gd --> goto definition...
        nmap <special> <buffer><silent> gd  :let @/ = TPV_locate_perl_var_decl()<CR>

        " tt --> toggle tracking...
        nmap <special> <buffer><silent> tt  :let b:track_perl_var_locked = ! b:track_perl_var_locked<CR>:call TPV_track_perl_var()<CR>

        " Adjust keywords to cover sigils and qualifiers...
        setlocal iskeyword+=$
        setlocal iskeyword+=%
        setlocal iskeyword+=@-@
        setlocal iskeyword+=:
        setlocal iskeyword-=,

        " Restore any frozen tracking...
        if b:track_perl_var_locked
            highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR_LOCKED
            try
                call matchadd('TRACK_PERL_VAR_ACTIVE', b:track_perl_var_locked_pat, 1000, s:match_id)
            catch /./
            endtry
        endif
    endif

endfunction


function! TPV__teardown ()
    " Remove any active highlighting...
    try
        call matchdelete(s:match_id)
    catch /./
    endtry

endfunction



"=====[ Implementation ]==========================================

" Track last highlighted var for xmaps...
let s:prev_sigil   = ""
let s:prev_varname = ""

" Select an unlikely match number (e.g. the Neighbours of the Beast)...
let s:match_id = 664668

" This tracks whether plugin is displaying a message...
let s:displaying_message = 0

" Set up initial highlight groups (unless already set)...
highlight default      TRACK_PERL_VAR             ctermfg=white                cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_QUESTION    ctermfg=white                cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_LOCKED      ctermfg=cyan   ctermbg=blue  cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_UNDECLARED  ctermfg=red                  cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_UNUSED      ctermfg=cyan                 cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_BUILTIN     ctermfg=magenta              cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default link TRACK_PERL_VAR_ACTIVE      TRACK_PERL_VAR

let s:PUNCT_VAR_DESC = {
\  "$'"                     :  'String following most recent regex match',
\  '$!'                     :  'Status from most recent system call (including I/O)',
\  '$"'                     :  'List separator for array interpolation',
\  '$#'                     :  'Output number format [deprecated: use printf() instead]',
\  '$$'                     :  'Process ID',
\  '$%'                     :  'Page number of the current output page',
\  '$&'                     :  'Most recent regex match string',
\  '$('                     :  'Real group ID of the current process',
\  '$)'                     :  'Effective group ID of the current process',
\  '$*'                     :  'Regex multiline matching flag [removed: use /m instead]',
\  '$+'                     :  'Final capture group of most recent regex match',
\  '$,'                     :  'Output field separator for print() and say()',
\  '$-'                     :  'Number of lines remaining in current output page',
\  '$.'                     :  'Line number of last input line',
\  '$/'                     :  'Input record separator (end-of-line marker on inputs)',
\  '$0'                     :  'Program name',
\  '$1'                     :  'First capture group from most recent regex match',
\  '$2'                     :  'Second capture group from most recent regex match',
\  '$3'                     :  'Third capture group from most recent regex match',
\  '$4'                     :  'Fourth capture group from most recent regex match',
\  '$5'                     :  'Fifth capture group from most recent regex match',
\  '$6'                     :  'Sixth capture group from most recent regex match',
\  '$7'                     :  'Seventh capture group from most recent regex match',
\  '$8'                     :  'Eighth capture group from most recent regex match',
\  '$9'                     :  'Ninth capture group from most recent regex match',
\  '$:'                     :  'Break characters for format() lines',
\  '$;'                     :  'Hash subscript separator for key concatenation',
\  '$<'                     :  'Real uid of the current process',
\  '$='                     :  'Page length of selected output channel',
\  '$>'                     :  'Effective uid of the current process',
\  '$?'                     :  'Status from most recent system call (including I/O)',
\  '$@'                     :  'Current propagating exception',
\  '$ARGV'                  :  'Name of file being read by readline() or <>',
\  '$['                     :  'Array index origin [deprecated]',
\  "$\\"                    :  'Output record separator (appended to every print())',
\  '$]'                     :  'Perl interpreter version [deprecated: use $^V]',
\  '$^'                     :  'Name of top-of-page format for selected output channel',
\  '$^A'                    :  'Accumulator for format() lines',
\  '$^C'                    :  'Is the program still compiling?',
\  '$^D'                    :  'Debugging flags',
\  '$^E'                    :  'O/S specific error information',
\  '$^F'                    :  'Maximum system file descriptor',
\  '$^H'                    :  'Internal compile-time lexical hints',
\  '$^I'                    :  'In-place editing value',
\  '$^L'                    :  'Form-feed sequence for format() pages',
\  '$^M'                    :  'Emergency memory pool',
\  '$^N'                    :  'Most recent capture group (within regex)',
\  '$^O'                    :  'Operating system name',
\  '$^P'                    :  'Internal debugging flags',
\  '$^R'                    :  'Result of last successful code block (within regex)',
\  '$^S'                    :  'Current eval() state',
\  '$^T'                    :  'Program start time',
\  '$^V'                    :  'Perl interpreter version',
\  '$^W'                    :  'Global warning flags',
\  '$^X'                    :  'Perl interpreter invocation name',
\  '$_'                     :  'Topic variable: default argument for matches and many builtins',
\  '$`'                     :  'String preceding most recent regex match',
\  '$a'                     :  'Block parameter: automatically provided to sort blocks',
\  '$b'                     :  'Block parameter: automatically provided to sort blocks',
\  '${^CHILD_ERROR_NATIVE}' :  'Native status from most recent system call',
\  '${^ENCODING}'           :  'Encode object for source conversion to Unicode',
\  '${^GLOBAL_PHASE}'       :  'Current interpreter phase',
\  '${^MATCH}'              :  'Most recent regex match string (under /p)',
\  '${^OPEN}'               :  'PerlIO I/O layers',
\  '${^POSTMATCH}'          :  'String following most recent regex match (under /p)',
\  '${^PREMATCH}'           :  'String preceding most recent regex match (under /p)',
\  '${^RE_DEBUG_FLAGS}'     :  'Regex debugging flags',
\  '${^RE_TRIE_MAXBUF}'     :  'Cache limit on regex optimizations',
\  '${^TAINT}'              :  'Taint mode',
\  '${^UNICODE}'            :  'Unicode settings',
\  '${^UTF8CACHE}'          :  'Internal UTF-8 offset caching controls',
\  '${^UTF8LOCALE}'         :  'UTF-8 locale',
\  '${^WARNING_BITS}'       :  'Lexical warning flags',
\  '${^WIN32_SLOPPY_STAT}'  :  'Use non-opening stat() under Windows',
\  '$|'                     :  'Autoflush status of selected output filehandle',
\  '$~'                     :  'Name of format for selected output channel',
\  '%!'                     :  'Status of all possible errors from most recent system call',
\  '%+'                     :  'Named captures of most recent regex match (as strings)',
\  '%-'                     :  'Named captures of most recent regex match (as arrays of strings)',
\  '%ENV'                   :  'The current shell environment',
\  '%INC'                   :  'Filepaths of loaded modules',
\  '%SIG'                   :  'Signal handlers',
\  '%^H'                    :  'Lexical hints hash',
\  '@+'                     :  'Offsets of ends of capture groups of most recent regex match',
\  '@-'                     :  'Offsets of starts of capture groups of most recent regex match',
\  '@ARGV'                  :  'Command line arguments',
\  '@F'                     :  'Fields of the current input line (under autosplit mode)',
\  '@INC'                   :  'Search path for loading modules',
\  '@_'                     :  'Subroutine arguments',
\}

let s:ENGLISH_NAME = {
\   '$!'  : '$OS_ERROR',
\   '$"'  : '$LIST_SEPARATOR',
\   "$'"  : '$POSTMATCH',
\   "$&"  : '$MATCH',
\   '$`'  : '$PREMATCH',
\   '$#'  : '$OFMT',
\   '$$'  : '$PROCESS_ID',
\   '$%'  : '$FORMAT_PAGE_NUMBER',
\   '$('  : '$REAL_GROUP_ID',
\   '$)'  : '$EFFECTIVE_GROUP_ID',
\   '$+'  : '$LAST_PAREN_MATCH',
\   '$,'  : '$OUTPUT_FIELD_SEPARATOR',
\   '$-'  : '$FORMAT_LINES_LEFT',
\   '$.'  : '$INPUT_LINE_NUMBER',
\   '$/'  : '$INPUT_RECORD_SEPARATOR',
\   '$0'  : '$PROGRAM_NAME',
\   '$:'  : '$FORMAT_LINE_BREAK_CHARACTERS',
\   '$;'  : '$SUBSCRIPT_SEPARATOR',
\   '$<'  : '$REAL_USER_ID',
\   '$='  : '$FORMAT_LINES_PER_PAGE',
\   '$>'  : '$EFFECTIVE_USER_ID',
\   '$?'  : '$CHILD_ERROR',
\   '$@'  : '$EVAL_ERROR',
\   '$['  : '$ARRAY_BASE',
\   "$\\" : '$OUTPUT_RECORD_SEPARATOR',
\   '$]'  : '$OLD_PERL_VERSION',
\   '$^'  : '$FORMAT_TOP_NAME',
\   '$^A' : '$ACCUMULATOR',
\   '$^C' : '$COMPILING',
\   '$^D' : '$DEBUGGING',
\   '$^E' : '$EXTENDED_OS_ERROR',
\   '$^F' : '$SYSTEM_FD_MAX',
\   '$^I' : '$INPLACE_EDIT',
\   '$^L' : '$FORMAT_FORMFEED',
\   '$^N' : '$LAST_SUBMATCH_RESULT',
\   '$^O' : '$OSNAME',
\   '$^P' : '$PERLDB',
\   '$^R' : '$LAST_REGEXP_CODE_RESULT',
\   '$^S' : '$EXCEPTIONS_BEING_CAUGHT',
\   '$^T' : '$BASETIME',
\   '$^V' : '$PERL_VERSION',
\   '$^W' : '$WARNING',
\   '$^X' : '$EXECUTABLE_NAME',
\   '$_'  : '$ARG',
\   '$|'  : '$OUTPUT_AUTOFLUSH',
\   '$~'  : '$FORMAT_NAME',
\   '%!'  : '%OS_ERROR',
\   '@+'  : '@LAST_MATCH_END',
\   '@-'  : '@LAST_MATCH_START',
\   '@_'  : '@ARG',
\}

let s:PUNCT_NAME = {
\   '$ERRNO'                        : '$!',
\   '$OS_ERROR'                     : '$!',
\   '$LIST_SEPARATOR'               : '$"',
\   '$POSTMATCH'                    : "$'",
\   '$MATCH'                        : "$&",
\   '$PREMATCH'                     : '$`',
\   '$OFMT'                         : '$#',
\   '$PID'                          : '$$',
\   '$PROCESS_ID'                   : '$$',
\   '$FORMAT_PAGE_NUMBER'           : '$%',
\   '$GID'                          : '$(',
\   '$REAL_GROUP_ID'                : '$(',
\   '$EFFECTIVE_GROUP_ID'           : '$)',
\   '$EGID'                         : '$)',
\   '$LAST_PAREN_MATCH'             : '$+',
\   '$OFS'                          : '$,',
\   '$OUTPUT_FIELD_SEPARATOR'       : '$,',
\   '$FORMAT_LINES_LEFT'            : '$-',
\   '$INPUT_LINE_NUMBER'            : '$.',
\   '$NR'                           : '$.',
\   '$INPUT_RECORD_SEPARATOR'       : '$/',
\   '$RS'                           : '$/',
\   '$PROGRAM_NAME'                 : '$0',
\   '$FORMAT_LINE_BREAK_CHARACTERS' : '$:',
\   '$SUBSCRIPT_SEPARATOR'          : '$;',
\   '$SUBSEP'                       : '$;',
\   '$REAL_USER_ID'                 : '$<',
\   '$UID'                          : '$<',
\   '$FORMAT_LINES_PER_PAGE'        : '$=',
\   '$EFFECTIVE_USER_ID'            : '$>',
\   '$EUID'                         : '$>',
\   '$CHILD_ERROR'                  : '$?',
\   '$EVAL_ERROR'                   : '$@',
\   '$ARRAY_BASE'                   : '$[',
\   '$ORS'                          : "$\\",
\   '$OUTPUT_RECORD_SEPARATOR'      : "$\\",
\   '$OLD_PERL_VERSION'             : '$]',
\   '$FORMAT_TOP_NAME'              : '$^',
\   '$ACCUMULATOR'                  : '$^A',
\   '$COMPILING'                    : '$^C',
\   '$DEBUGGING'                    : '$^D',
\   '$EXTENDED_OS_ERROR'            : '$^E',
\   '$SYSTEM_FD_MAX'                : '$^F',
\   '$INPLACE_EDIT'                 : '$^I',
\   '$FORMAT_FORMFEED'              : '$^L',
\   '$LAST_SUBMATCH_RESULT'         : '$^N',
\   '$OSNAME'                       : '$^O',
\   '$PERLDB'                       : '$^P',
\   '$LAST_REGEXP_CODE_RESULT'      : '$^R',
\   '$EXCEPTIONS_BEING_CAUGHT'      : '$^S',
\   '$BASETIME'                     : '$^T',
\   '$PERL_VERSION'                 : '$^V',
\   '$WARNING'                      : '$^W',
\   '$EXECUTABLE_NAME'              : '$^X',
\   '$ARG'                          : '$_',
\   '$OUTPUT_AUTOFLUSH'             : '$|',
\   '$FORMAT_NAME'                  : '$~',
\   '%ERRNO'                        : '%!',
\   '%OS_ERROR'                     : '%!',
\   '@LAST_MATCH_END'               : '@+',
\   '@LAST_PAREN_MATCH'             : '@+',
\   '@LAST_MATCH_START'             : '@-',
\   '@ARG'                          : '@_',
\}

for [punctvar, engvar] in items(s:ENGLISH_NAME)
    let s:PUNCT_VAR_DESC[engvar] = s:PUNCT_VAR_DESC[punctvar]
endfor

let s:ORDINAL = { '1':'st', '2':'nd', '3':'rd' }

let s:MATCH_VAR_PAT = join([
\     '\(',
\         '[@%]\zs[$]',
\     '\|',
\         '[@%]\K\@=',
\     '\|',
\         '[$]\zs[$]\K\@=',
\     '\|',
\         '[$]',
\     '\|',
\         '[@%]\zs[$][.!*?:]',
\     '\|',
\         '\%(->\)\@<![@%][.!*?:]',
\     '\|',
\         '[$][#.!*?:]',
\     '\|',
\         '[$]\zs[$][#.!*?:]\K\@=',
\     '\)',
\     '\s*',
\     '\(',
\         '\d\+',
\     '\|',
\         '\K\k*',
\     '\|',
\         '\^\K\k*',
\     '\|',
\         '[{]\d\+[}]',
\     '\|',
\         '[{]\^\h\w*[}]',
\     '\|',
\         '[{][$]\@!\K\k*[}]',
\     '\|',
\         '[{][[:punct:]][}]',
\     '\|',
\         '[{]\@![[:punct:]]',
\     '\)'
\ ], '')

" This gets called every time the cursor moves (so keep it tight!)...
function! TPV_track_perl_var ()
    " Is tracking locked???
    highlight TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
    if b:track_perl_var_locked
        highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR_LOCKED
        return
    else
        highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR
    endif

    " Remove previous highlighting...
    try | call matchdelete(s:match_id) | catch /./ | endtry

    " Locate a var under cursor...
    let cursline = getline('.')
    let curscol  = col('.')

    let varparts
    \    = matchlist(cursline, '\%<'.(curscol+1).'c'.s:MATCH_VAR_PAT.'\%>'.curscol.'c\s*\([[{]\)\?')

    " Short-circuit if nothing to track...
    if empty(varparts)
        if s:displaying_message
            echo ""
            let s:displaying_message = 0
        endif
        let s:prev_sigil   = ""
        let s:prev_varname = ""
        return
    endif

    " Otherwise, extract components of variable...
    let sigil   = get(varparts,1)
    let varname = substitute(get(varparts,2), '^[{]\([^^]\_.*\)[}]$', '\1', '')
    let esc_varname = escape(substitute( varname, '^{\([^^].*\)}$', '\1', 'g'),'\\')
    let bracket = get(varparts,3,'')

    " Do we need to bound the varname???
    let boundary = varname =~ '\w$' ? '\>' : ''

    " Handle arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
        let sigil = '@'
        let curs_var = '\C\%('
                \ . '[$%]\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\%(\_s*[[]\)\@=\|'
                \ . '[$]#\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\|'
                \ .  '[@]\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\%(\_s*[{]\)\@!'
                \ . '\)'

    " Handle hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
        let sigil = '%'
        let curs_var = '\C\%('
                \ . '[$@]\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\%(\_s*[{]\)\@=\|'
                \ .  '[%]\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\%(\_s*[[]\)\@!'
                \ . '\)'

    " Handle scalars: $scalar
    else
        let sigil = '$'
        let curs_var = '\C[$]\_s*\%('.esc_varname.boundary.'\|{'.esc_varname.'}\)\%(\_s*[[{]\)\@!'
    endif

    " Special highlighting and descriptions for builtins...
    let desc = get(s:PUNCT_VAR_DESC, sigil.varname,
             \     varname =~ '^\d\+$'
             \      ? varname . get(s:ORDINAL,varname[-1:],'th') . ' capture group of most recent regex match'
             \      : ''
             \ )
    if len(desc)
        highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
        highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_BUILTIN

        echohl TRACK_PERL_VAR_BUILTIN
        echo s:truncate(sigil.varname . ': ' . desc)
        echohl None
        let s:displaying_message = 1

    " Special highlighting for undeclared variables...
    elseif varname !~ ':' && !search(TPV_gen_decl_pat_for(sigil,varname), 'Wbnc')
        highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
        highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_UNDECLARED
        echohl TRACK_PERL_VAR_UNDECLARED
        echo 'Undeclared variable'
        echohl None
        let s:displaying_message = 1

    " Special highlighting for singleton variables...
    elseif varname !~ ':' && searchpos('\<'.curs_var, 'wn') == searchpos('\<'.curs_var,'bcwn')
        highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
        highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_UNUSED
        echohl TRACK_PERL_VAR_UNUSED
        echo 'Unused variable'
        echohl None
        let s:displaying_message = 1

    " Special highlighting for ordinary variables...
    else
        highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
        highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR

        " Does this var have a descriptive comment???
        let new_message = 0
        let decl_pat = TPV_gen_decl_pat_for(sigil,varname)
        let decl_line_num = search(decl_pat, 'Wcbn')
        if decl_line_num   " Ugly nested if's to minimize computation per cursor move...
            let decl_line = getline(decl_line_num)
            let decl_start_pat = TPV_gen_decl_pat_for(sigil,varname,'start')
            let decl_start_line_num = search(decl_start_pat, 'Wcbn')
            let decl_type = substitute(matchlist(join(getline(decl_start_line_num,decl_line_num),' '), '^.*\<\(my\|our\|state\|local\|sub\)\%([^;[:alnum:]][^;]*\)\?'.sigil.varname)[1],'^sub','param','')
            if decl_line =~ '\s#\s'
                let decl_line = substitute(decl_line, '.*\s#\s', sigil.varname.': ', '')
            else
                let decl_line = sigil.varname
            endif
            echohl TRACK_PERL_VAR
            echo s:truncate(decl_type.' '.decl_line)
            echohl None
            let s:displaying_message = 1
            let new_message = 1
        endif

        if s:displaying_message && !new_message
            echo ""
            let s:displaying_message = 0
        endif
    endif

    " Set up the match for variables...
    let b:track_perl_var_locked_pat = curs_var.'\%(\_$\|\W\@=\)'
    try
        call matchadd('TRACK_PERL_VAR_ACTIVE', b:track_perl_var_locked_pat, 1000, s:match_id)
    catch /./
    endtry

    " Remember the variable...
    let s:prev_sigil   = sigil
    let s:prev_varname = varname
endfunction


" Generate pattern to match variable declaration

function! TPV_gen_decl_pat_for (sigil,varname,...)
    let ows = '\%(\_s\+\|#.*\)*'
    let start = a:0 ? '' : '\zs'
    return '\C\<\(my\|our\|state\|local\|sub\>'.ows.'\w*'.ows.'[(]\@=\)'.ows
        \. '\%([(]'.ows.'\%([%$@]\w*\>'.ows.'\%(=[^,]*\)\?,'.ows.'\)*\)\?'
        \. start . '[' . a:sigil . ']' . a:varname . '\>'
endfunction


" Implement "locate next use of a variable" (i.e. * command)

function! TPV_locate_perl_var ()
    " Locate a var under cursor...
    let cursline = getline('.')
    let curscol  = col('.')

    let varparts
    \    = matchlist(cursline, '\%<'.(curscol+1).'c'.s:MATCH_VAR_PAT.'\%>'.curscol.'c\s*\([[{]\)\?')

    " Revert to generic behaviour if not on a variable
    if empty(varparts)
        exec b:old_star_map ? b:old_star_map : 'normal! *'
        return @/
    endif

    " Otherwise, extract components of variable...
    let sigil   = get(varparts,1)
    let varname = substitute(get(varparts,2), '^[{]\(.*\)[}]$', '\1', '')
    let bracket = get(varparts,3,'')

    " Handle arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
        let sigil = '@'
        let curs_var = '\C\%('
                   \ . '[$%]\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\%(\_s*[[]\)\@=\|'
                   \ . '[$]#\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\|'
                   \ .  '[@]\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\%(\_s*[{]\)\@!'
                   \ . '\)'

    " Handle hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
        let sigil = '%'
        let curs_var = '\C\%('
                   \ . '[$@]\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\%(\_s*[{]\)\@=\|'
                   \ .  '[%]\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\%(\_s*[[]\)\@!'
                   \ . '\)'

    " Handle scalars: $scalar
    else
        let sigil = '$'
        let curs_var = '\C[$]\_s*\%('.varname.'\>\ze\|{'.varname.'}\ze\)\%(\_s*[[{]\)\@!'
    endif

    " Finally, search forwards for the declaration and report the outcome...
    call search('\<'.curs_var, 's')
    return curs_var

endfunction


" Implement "locate preceding declaration of a variable" (i.e. @ command)

function! TPV_locate_perl_var_decl ()
    " Locate a var under cursor...
    let cursline = getline('.')
    let curscol  = col('.')

    let varparts
    \    = matchlist(cursline, '\%<'.(curscol+1).'c'.s:MATCH_VAR_PAT.'\%>'.curscol.'c\s*\([[{]\)\?')

    " Warn if nothing to locate...
    if empty(varparts)
        echohl WarningMsg
        echo "Can't locate a declaration (cursor is not on a variable)"
        echohl None
        return @/
    endif

    " Otherwise, extract components of variable...
    let sigil   = get(varparts,1)
    let varname = substitute(get(varparts,2), '^[{]\(.*\)[}]$', '\1', '')
    let bracket = get(varparts,3,'')

    " Identify arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
        let sigil = '@'

    " Identify hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
        let sigil = '%'

    " Identify scalars: $scalar
    else
        let sigil = '$'
    endif

    " Ignore builtins...
    if len( get(s:PUNCT_VAR_DESC, sigil.varname, '') ) || len( get(s:PUNCT_VAR_DESC, sigil.'{'.varname.'}', '') )
        echohl TRACK_PERL_VAR_BUILTIN
        echo "Builtins don't have declarations"
        echohl None
        return @/
    endif

    " Otherwise search backwards for the declaration and report the outcome...
    let decl_pat = TPV_gen_decl_pat_for(sigil,varname)
    if !search(decl_pat, 'Wbs')
        echohl WarningMsg
        echo "Can't find a declaration before this point"
        echohl None
        return @/
    endif

    return decl_pat

endfunction


" Implement "rename all forms of a variable" (i.e. cv command)

function! TPV_rename_perl_var (mode) range
    " Grab the currently highlighted variable (if any)...
     let sigil   = s:prev_sigil
     let varname = s:prev_varname

    if empty(sigil)
        echohl WarningMsg
        echo "Nothing to rename (cursor is not on a variable)"
        echohl None
        return
    endif

    " Handle punctuation variables
    let esc_varname = varname == '\' ? '[\\]' : varname == '!' ? '[!]' : substitute(varname, '[][~$*/.]', '[\0]', 'g')
    let esc_varname = substitute(esc_varname, '\^', "\\^", 'g')
    let esc_varname = substitute(esc_varname, '\w\zs$', '\\>', 'g')

    " Handle arrays: @array, $array[...], @array[...], %array[...], $#array...
    if sigil == '@'
        let curs_var = '\C\%('
                   \ . '[$%]\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\%(\_s*[[]\)\@=\|'
                   \ . '[$]#\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\|'
                   \ .  '[@]\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\%(\_s*[{]\)\@!'
                   \ . '\)'

    " Handle hashes: %hash, $hash{...}, @hash{...}, %hash{...}...
    elseif sigil == '%'
        let curs_var = '\C\%('
                   \ . '[$@]\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\%(\_s*[{]\)\@=\|'
                   \ .  '[%]\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\%(\_s*[[]\)\@!'
                   \ . '\)'

    " Handle scalars: $scalar
    else
        let curs_var = '\C[$]\_s*\%(\zs'.esc_varname.'\ze\|{\zs'.esc_varname.'\ze}\)\%(\_s*[[{]\)\@!'
    endif

    " Does it have a default?
    let def_new_varname = substitute(get(s:PUNCT_NAME,sigil.varname, get(s:ENGLISH_NAME,sigil.varname, "")),'[$@%]','','')

    " Request the new name...
    echohl TRACK_PERL_VAR_QUESTION
    let context = a:mode == 'normal' ? 'Globally' : 'Within visual selection'
    call inputsave()
    let new_varname = input(context . ' rename variable ' . sigil . varname . ' to: ' . sigil, def_new_varname)
    call inputrestore()
    echohl None
    if new_varname ==# varname || new_varname == ""
        echohl WarningMsg
        echo "Cancelled"
        echohl None
        return
    endif

    " Verify that it's safe...
    let check_new_var = substitute('\<'.curs_var, escape(varname,'\'), new_varname, 'g')
    if varname !~ '\W' && search(check_new_var, 'wnc')
        echohl TRACK_PERL_VAR_QUESTION
        echon "\rA variable named " . sigil . new_varname . ' already exists. Proceed anyway? '
        echohl None
        let response = nr2char(getchar())
        echon response
        echo ""
        if response =~ '^[^Yy]'
            echohl WarningMsg
            echo "Cancelled"
            echohl None
            return
        endif
    endif

    " Apply the transformation...
    let range = (a:mode == 'normal' ? '%' : a:firstline . ',' . a:lastline)
    exec range . 's/\<' . curs_var . '/' . escape(new_varname,'\') . '/g'

    " Return to original position...
    normal ``

    " Circumvent the default gv after a vcv...
    if a:mode == 'visual'
        exec 'nmap <silent> gv  :nmap gv ' . maparg('gv','n') . '<CR>'
    endif
endfunction

function! s:truncate (str)
    let width = winwidth(0) - (&ruler ? str2nr(get(matchlist(&rulerformat,'^%\(\d\+\)'),1,17))+2 : 0)
    return strwidth(a:str) > width ? strpart(a:str,0,width-3).'...' : a:str
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo
