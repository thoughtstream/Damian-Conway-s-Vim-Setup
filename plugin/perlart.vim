" Vim global plugin for Perl Analysis, Refactoring, and Tracking
"
" Last change:  Wed May 24 12:26:16 CEST 2017

" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_perlart")
    finish
endif
let loaded_perlart = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim


"=====[ Refactor a visual block of Perl code ]===============

" INTERFACE...

function! PerlART_SetHighlights ()
    " Set these highlight groups in your .vimrc to change the default appearance

    " Information messages...
    highlight default PerlART_Error                ctermfg=red         cterm=bold
    highlight default PerlART_Problem              ctermfg=black       ctermbg=lightred
    highlight default PerlART_Message              ctermfg=cyan        cterm=bold
    highlight default PerlART_LineNr               ctermfg=blue        cterm=bold

    " How Perl built-in variables will be displayed...
    highlight default PerlART_BuiltIn              ctermfg=lightmagenta

    " How undeclared variables will be displayed...
    highlight default PerlART_Undeclared           ctermfg=red         cterm=bold

    " How declarations of variables that are never used will be displayed...
    highlight default PerlART_Unused               ctermfg=red         cterm=italic
    highlight default PerlART_LexicalDeclUnused    ctermfg=darkred     ctermbg=cyan       cterm=italic
    highlight default PerlART_StaticDeclUnused     ctermfg=darkred     ctermbg=lightblue  cterm=italic
    highlight default PerlART_PackageDeclUnused    ctermfg=darkred     ctermbg=magenta    cterm=italic
    highlight default PerlART_UndeclaredDeclUnused ctermfg=red

    " How the declarations and usages of my variables will be displayed...
    highlight default PerlART_LexicalDecl          ctermfg=black       ctermbg=cyan
    highlight default PerlART_Lexical              ctermfg=cyan

    " How the declarations and usages of state variables will be displayed...
    highlight default PerlART_StaticDecl           ctermfg=black       ctermbg=lightblue
    highlight default PerlART_Static               ctermfg=lightblue

    " How the declarations and usages of our variables will be displayed...
    highlight default PerlART_PackageDecl          ctermfg=black       ctermbg=magenta
    highlight default PerlART_Package              ctermfg=magenta

    " Set this highlight group to anything except Normal, to turn on scope bars...
    highlight default link  PerlART_ScopeBar     Normal

    " Scope bars of different lengths will then be displayed as follows...
    highlight default PerlART_Scope_Small          ctermfg=black       ctermbg=blue
    highlight default PerlART_Scope_Medium         ctermfg=black       ctermbg=darkyellow
    highlight default PerlART_Scope_Large          ctermfg=black       ctermbg=red

    " How multiple selections of code to be refactored will be highlighted...
    highlight default link  PerlART_Selection    Visual

    " How easily confused variable names will be displayed...
    highlight default link  PerlART_Homograms    Normal

    " How easily confused variable names will be displayed...
    highlight default link  PerlART_Parograms    Normal

    " How insufficiently descriptive variable names will be displayed...
    highlight default link  PerlART_Cacograms    Normal

endfunction


" Available keymappings (change these to suit your own preferences)...
function! PerlART_API_setup () abort
    " Rename the variable under the cursor...
    silent nmap     <silent><buffer><expr>      <C-N>        PerlART_RenameVariable()

    " Search for all instances of the variable under the cursor...
"    silent nmap     <silent><buffer><expr>      <C-F>        PerlART_MatchAllUses()

    " Jump to the declaration of the variable under the cursor...
    silent nmap     <silent><buffer><expr>      gd           PerlART_GotoDefinition()

    " Jump to the next instance of the variable under the cursor...
    silent nmap     <silent><buffer><special>   *            :silent call PerlART_GotoNextUse()<CR>

    " In visual mode, hoist into a variable all instances of the variable under the cursor...
    silent xnoremap <silent><buffer><expr>      <C-H>        PerlART_HoistExpr('all','variable')

    " In visual mode, hoist into a closure all instances of the variable under the cursor...
    silent xnoremap <silent><buffer><expr>      <C-C>        PerlART_HoistExpr('all','closure')

    " In visual mode, hoist into a subroutine all instances of the variable under the cursor...
    silent xnoremap <silent><buffer><expr>      <C-R>        PerlART_RefactorToSub('all')

    " Doubling the trigger causes only the single instance under the cursor to be refactored...
    silent xnoremap <silent><buffer><expr>      <C-H><C-H>   PerlART_HoistExpr('one','variable')
    silent xnoremap <silent><buffer><expr>      <C-C><C-C>   PerlART_HoistExpr('one','closure')
    silent xnoremap <silent><buffer><expr>      <C-S><C-S>   PerlART_RefactorToSub('one')
endfunction

" These happen automatically...
augroup PerlRefactor
    autocmd!
    autocmd FileType    perl    silent call PerlART_API_setup()
    autocmd FileType    perl    silent call PerlART_SetHighlights()
    autocmd ColorScheme *       if &filetype == 'perl' | silent call PerlART_SetHighlights() | endif

    autocmd CursorHold  *.p[lm],*.t  call PerlART_RunVarAnalysis()
    autocmd BufRead     *.p[lm],*.t
    \    if get(b:,'PerlART_tick',-1) < b:changedtick | call PerlART_RunCodeAnalysis() | endif
    autocmd CursorHold  *.p[lm],*.t
    \    if get(b:,'PerlART_tick',-1) < b:changedtick | call PerlART_RunCodeAnalysis() | endif
augroup END


" Set this variable in your .vimrc to preconfigure the Perl-based subroutine refactoring...
" For example, to change the default names for refactored subroutines and hoisted lexicals:
"
"    let g:PerlART_sub_name   = "NEW_SUB"


"=======================================================================
" IMPLEMENTATION...


"=====[ Variable renaming ]=========

function! PerlART_VarRename () abort
    call setpos("'r", getcurpos())

    " Find the character offset of the desired (cursored) variable in the source code...
    let var_offset = wordcount()['cursor_chars'] - 1

    " Grab the entire source code from the buffer...
    let src = join(getline(1,'$'), "\n")

    " Get the full name of the variable under the cursor...
    let cmd = printf("perl -MCode::ART -E'get_variable_for_Vim(%d)'", var_offset)
    let var_name = substitute(system(cmd, src), '\n', '', 'g')
    if var_name == ""
        echohl WarningMsg
        echo "Can't rename there (cursor is not over a variable)"
        echohl NONE
        return
    endif

    " Ask for the new name...
    call inputsave()
    echohl WarningMsg
    let new_name = input('Rename ' . var_name . ' to: ' . var_name[0])
    echohl NONE
    call inputrestore()

    " Allow them to cancel by entering a blank name...
    if new_name =~ "^\s*$"
        return
    endif

    " Call out to Code::ART to do the hard work...
    let cmd = printf(
    \   "perl -MCode::ART -E'rename_variable_for_Vim(%d, q{%s})'", var_offset, new_name
    \)
    let new_lines = systemlist(cmd, src)

    " Report any failure or install the updated code...
    if new_lines[0] =~ '^----'
        echohl WarningMsg
        echo strpart(new_lines[0],4)
        echohl NONE
    else
        call setline(line('.'), '')
        call setline(1, new_lines)
    endif
endfunction

"=====[ Code refactoring ]=========

let s:MISSING_RETURN_STATEMENT = '# RETURN VALUE HERE?'

" Provide list of possible variables to complete return statement...
function! PerlART_complete (ArgLead, CmdLine, CursorPos)
    return b:PRcomplete_vars
endfunction

" Do the refactoring...
function! PerlART_RefactorToSub (what) range
    return "\"sygv:\<C-U>'<,'>call PerlART_perform_refactor('".a:what."', '".mode()."')\<CR>"
endfunction

function! PerlART_perform_refactor (what, mode) abort range
    " Get the old code's location...
    let [buf, startline, startcol, etc] = getpos("'<")
    let [buf,   endline,   endcol, etc] = getpos("'>")
    if a:mode ==# 'V'
        let [startbyte, endbyte] = [line2byte(startline)-1, line2byte(endline+1)-2]
    else
        let [startbyte, endbyte] = [line2byte(startline)+startcol-2, line2byte(endline)+endcol-2]
    endif

    " Save original target code as a searchable pattern and highlight all instances...
    if a:what == 'all'
        let target_code = '\M'.escape(trim(@s), "\\")
        call PerlART_matchadd('PerlART_Selection', target_code, 100)
        redraw
    endif

    " Get the new sub's name...
    let how_much = a:what == 'all' ? ' every instance of this code ' : ' this code only '
    let newname = Ask("Refactor".how_much."as: sub ", get(g:, 'PerlART_sub_name', 'SUBNAME'))
    if newname == "\<ESC>"
        call PerlART_matchclear('PerlART_Selection')
        redraw!
        normal! gv
        return
    endif


    " Set up the arguments for the Perl script that does all the hard work...
    let options = '{ name => q{' . newname   . '}, '
    \           . '  from => '   . startbyte . ',  '
    \           . '  to   => '   . endbyte   . ',  '
    \           . '}'

    " Call the script and unpack the results...
    let refactored = eval(
                   \    substitute(
                   \      system(
                   \         "perl -MCode::ART::API::Vim -e 'refactor_to_sub(" . options . ")'",
                   \         join(getline(1, '$'), "\n")
                   \      ),
                   \      '\n', '', 'g'
                   \    )
                   \ )

    if has_key(refactored, 'failed')
        echohl  PerlART_Error
        echomsg "Can't refactor selected code (" . refactored['failed'] . ")"
        echohl  NONE
        call PerlART_matchclear('PerlART_Selection')
        normal gv
        return
    endif

    let refactored_call   = refactored['call']
    let refactored_code   = refactored['code']
    let return_candidates = refactored['return']

    " Prompt for a return statement, if one seems to be needed...
    if refactored_code =~ s:MISSING_RETURN_STATEMENT
        let b:PRcomplete_vars = join(keys(return_candidates), "\n")
        call inputsave()
        let return_val = input("Return statement: return ", "", "custom,PerlART_complete")
        call inputrestore()
        if !empty(return_val)
            let refactored_code
            \   = substitute(refactored_code,
            \                s:MISSING_RETURN_STATEMENT,
            \                'return ' . get(return_candidates, return_val, escape(return_val,'\')) . ';', '')
        else
            let refactored_code
            \   = substitute(refactored_code, '\_s*'.s:MISSING_RETURN_STATEMENT.'\_s*', "\n", '')
        endif
    endif

    " Install the replacement code...
    let @s = refactored_call
    if a:mode ==? 'v'
        silent normal! gv"sp
    else
        silent normal! gvv"sp
    endif

    " Install everywhere, if requested...
    call PerlART_matchclear('PerlART_Selection')
    if a:what == 'all'
        try
            silent exec 'silent %s/' . escape(target_code, '/') . '/' . escape(trim(@s),'\\/') . '/g'
        catch
        endtry
    endif

    " Put the subroutine definition into the nameless and "s registers, ready for pasting
    let @" = refactored_code . "\n"
    let @s = refactored_code . "\n"

endfunction

let s:PerlART_highlight = {
\    'my' : 'PerlART_Lexical',
\ 'state' : 'PerlART_Static',
\   'our' : 'PerlART_Package',
\   'sub' : 'PerlART_Lexical',
\   'for' : 'PerlART_Package'
\}

function! PerlART_RunVarAnalysis () abort
    " Kill any incomplete analysis...
    if has_key(b:,'PerlART_RVA_job')
        call job_stop(b:PerlART_RVA_job)
    endif

    " Start a new analysis...
    let code = 'classify_var_at('.wordcount()['cursor_chars'].');'
    let b:PerlART_RVA_job
        \ = job_start(['perl', '-MCode::ART::API::Vim', '-E', code],
                      \{"in_io" : "buffer", "in_name" : "%", "out_cb": "PerlART_HandleVarAnalysis"})
endfunction

let s:PerlART_MatchID_Decl      = 664668
let s:PerlART_MatchID_Usage     = 668664
let s:PerlART_MatchID_Homograms = 665667
let s:PerlART_MatchID_Parograms = 663668
let s:PerlART_MatchID_ScopeBar  = 667665

function! PerlART_HandleVarAnalysis (channel, msg)
    let b:PerlART_cursvar = eval(a:msg)

    for m in getmatches()
        if m['id'] =~ '66\d66\d'
            call matchdelete(m['id'])
        endif
    endfor

    if has_key(b:PerlART_cursvar, 'failed')
        echo
        redraw
        return
    endif

    let declarator = get(b:PerlART_cursvar, 'declarator', '')
    let declloc    = get(b:PerlART_cursvar, 'declared_at', -1)
    if empty(declarator) && declloc >= 0
        let declarator = 'my'
    endif
    let is_undeclared = b:PerlART_cursvar['declared_at'] < 0
    \                && !b:PerlART_cursvar['is_builtin']
    \                && b:PerlART_cursvar['raw_name'] !~ '::\|'''

    let hl = get(s:PerlART_highlight, declarator, ( b:PerlART_cursvar['is_builtin']      ? 'PerlART_BuiltIn'
             \                               : b:PerlART_cursvar['raw_name'] =~ '::\|''' ? 'PerlART_Package'
             \                               :                                     'PerlART_Undeclared'
             \                               ))
    if declloc >= 0
        if empty(b:PerlART_cursvar['used_at'])
            call PerlART_matchadd(hl.'DeclUnused', b:PerlART_cursvar['declloc'].b:PerlART_cursvar['matchname'], 10, s:PerlART_MatchID_Decl)
        else
            call PerlART_matchadd(hl.'Decl', b:PerlART_cursvar['declloc'].b:PerlART_cursvar['matchname'], 10, s:PerlART_MatchID_Decl)
        endif
    endif
    call PerlART_matchadd(hl, b:PerlART_cursvar['matchloc'].b:PerlART_cursvar['matchname'], 9, s:PerlART_MatchID_Usage)

    if b:PerlART_cursvar['homograms'] != ''
        let homograms = '\%(' . b:PerlART_cursvar['homograms'] . '\)'
        call PerlART_matchadd('PerlART_Homograms', homograms.'\k\@!''\@!', 0, s:PerlART_MatchID_Homograms)
    endif

    if b:PerlART_cursvar['parograms'] != ''
        let parograms = '\%(' . b:PerlART_cursvar['parograms'] . '\)'
        call PerlART_matchadd('PerlART_Parograms', parograms.'\k\@!''\@!', 0, s:PerlART_MatchID_Parograms)
    endif

    if synIDtrans(hlID('PerlART_ScopeBar')) != synIDtrans(hlID('Normal'))
        if b:PerlART_cursvar['scope_size']  < 10
            call PerlART_matchadd('PerlART_Scope_Small',  '\%1c'.b:PerlART_cursvar['scopeloc'], 102, s:PerlART_MatchID_ScopeBar)
        elseif b:PerlART_cursvar['scope_scale'] < 0.2
            call PerlART_matchadd('PerlART_Scope_Medium', '\%1c'.b:PerlART_cursvar['scopeloc'], 102, s:PerlART_MatchID_ScopeBar)
        else
            call PerlART_matchadd('PerlART_Scope_Large',  '\%1c'.b:PerlART_cursvar['scopeloc'], 102, s:PerlART_MatchID_ScopeBar)
        endif
    endif

    let linenum_width = strlen(line('$'))
    let linenum = get(b:PerlART_cursvar, 'declared_at', -1) >= 0 ? byte2line(b:PerlART_cursvar['declared_at']-1)
    \                                                    : repeat('-', linenum_width)
    echohl PerlART_LineNr
    echo printf('%*s: ', linenum_width, linenum)

    exec 'echohl ' . hl
    echon (empty(declarator) ? '' : declarator . ' ')
       \. (declarator ==# 'sub' ? '(' . get(b:PerlART_cursvar, 'decl_name', '') . ')' : get(b:PerlART_cursvar, 'decl_name', '') )
       \. ( !empty(get(b:PerlART_cursvar, 'desc', ''))  ? '   # ' . b:PerlART_cursvar['desc'] : '' )
       \. ( !len(b:PerlART_cursvar['used_at'])          ? '  [unused]'
       \  : is_undeclared                       ? '  [undeclared]'
       \  : b:PerlART_cursvar['is_cacogram']
       \    && synIDtrans(hlID('PerlART_Cacograms')) != synIDtrans(hlID('Normal'))
       \                                        ? '  [needs a more descriptive name?]'
       \  :                                       ''
       \  )
    echohl NONE

    if &foldexpr == 'FS_FoldSearchLevel()'
        let @/ = b:PerlART_cursvar['matchloc'].b:PerlART_cursvar['matchname']
        normal zx
    endif
endfunc

function! PerlART_RenameVariable () abort
    " Are we actually on a variable?
    if has_key(b:PerlART_cursvar, 'failed')
        echohl PerlART_Error
        echo 'Please place the cursor over a variable and try again'
        echohl NONE
        return ''
    endif

    " What's the new name???
    func! PerlART_rename_aliases (A,C,P)
        return map(keys(get(b:PerlART_cursvar,'aliases',{})), {_,v -> strpart(v,1)})
    endfunc
    echohl PerlART_Message
    let g:new_name = input('Rename '.b:PerlART_cursvar['decl_name'].' --> '.b:PerlART_cursvar['sigil'],
                \          '', 'customlist,PerlART_rename_aliases')
    echohl NONE

    " A blank input cancels the rename...
    if g:new_name =~ '^\s*$'
        echohl PerlART_Warning
        echo 'Rename cancelled'
        echohl NONE
        return ''
    endif

    if b:PerlART_cursvar['is_builtin'] && !has_key(b:PerlART_cursvar['aliases'], b:PerlART_cursvar['sigil'].g:new_name)
        if Ask( 'Globally renaming ' . b:PerlART_cursvar['decl_name']
        \     . ' to '.  b:PerlART_cursvar['sigil'].g:new_name
        \     . " will remove its special behaviour. Proceed anyway? [yn] ", 'no'
        \     ) !~ '^\s*[Yy]'
            echohl PerlART_Error
            echo 'Rename cancelled'
            echohl NONE
            return ''
        endif
    endif

    return ':%s/' . b:PerlART_cursvar['matchloc'].b:PerlART_cursvar['matchnameonly'] . '/\=g:new_name/g' . "\<CR>``"
endfunction

function! PerlART_GotoDefinition () abort
    if has_key(b:PerlART_cursvar, 'failed')
        echohl PerlART_Error
        echo   'Please place the cursor over a variable and try again'
        echohl NONE
        return ""
    elseif get(b:PerlART_cursvar, 'declared_at', -1) < 0
        echohl PerlART_Error
        echo   'This variable has no declaration in the current file'
        echohl NONE
        return ""
    else
        return '/'.b:PerlART_cursvar['declloc'].b:PerlART_cursvar['matchname']."\<CR>"
    endif
endfunction

function! PerlART_GotoNextUse () abort
    if has_key(get(b:,'PerlART_cursvar',{'failed':1}), 'failed')
        silent normal! *
    else
        let @/ = b:PerlART_cursvar['matchloc'].b:PerlART_cursvar['matchname']
        normal n
    endif
endfunction

function! PerlART_MatchAllUses () abort
    if !has_key(b:PerlART_cursvar, 'failed')
        let @/ = b:PerlART_cursvar['matchloc'].b:PerlART_cursvar['matchname']
        return "/\<CR>``"
    endif
endfunction

function! PerlART_HoistExpr (one_all, kind) range
    return '"vygv'
         \ . ":\<C-U>'<,'>call PerlART_Impl_HoistExpr('".mode()."',".(a:one_all=='all').",'".a:kind."')\<CR>"
endfunction

function! PerlART_Impl_HoistExpr (mode, all, kind) abort range
    " We may need to change the kind later...
    let kind = a:kind

    " Get the old code's location...
    let [buf, startline, startcol, etc] = getpos("'<")
    let [buf,   endline,   endcol, etc] = getpos("'>")
    if a:mode ==# 'V'
        let [startbyte, endbyte] = [line2byte(startline), line2byte(endline+1)-1]
    else
        let [startbyte, endbyte] = [line2byte(startline)+startcol-1, line2byte(endline)+endcol-1]
    endif


    " Analyze the file to locate replaceable instances of the expression...
    let expr_scope = eval(
    \   system('perl -MCode::ART::API::Vim -e"find_expr_scope('.startbyte.','.endbyte.','.a:all.')"',
    \          join(getline(1,'$'),"\n"))
    \)

    " Can't hoist the selection (not an expression)...
    if has_key(expr_scope, 'failed')
        echohl PerlART_Error
        echomsg "Can't hoist "
        \  . (a:all ? 'multiple instances of that expression' : 'that expression')
        \  . " (because " . expr_scope['failed'] . ')'
        echohl None
        return
    endif

    " Handle mutators...
    if kind == 'variable' && expr_scope['mutators'] > 0 && expr_scope['matchcount'] > 1
        let kind = 'closure'
    endif

    " Show the targets for hoisting...
    let multiselect = matchadd('PerlART_Selection', expr_scope['matchloc'], 100)
    redraw

    " Get default name
    let default_name = substitute(@v, '^\W\+\|\W\+$', '', 'g')
    let default_name = substitute(default_name, '\W\+', '_', 'g')
    if default_name !~ '\a'
        let default_name = 'variable'
    endif
    let default_name = (kind == 'variable' ? '$' : '') . default_name
    if strchars(default_name) > 30
        let default_name = strcharpart(default_name,0,20) . '_etc'
    endif

    " Detemine the name of the new hoist variable...
    let varname = Ask( 'Hoist '
                \    . (a:all && expr_scope['matchcount'] > 1
                \          ? 'all these expressions'
                \          : 'this expression only' )
                \    . ' to a ' . kind . ' named: ',
                \      default_name)
    let varname  = substitute(varname, '^\s\+', '', '')
    let varsubst = varname
    if varname == ""
        let varname  = default_name
        let varsubst = default_name
    endif
    if varname !~ '^[$@%]'
        if kind == 'variable'
            let varname  = '$'.varname
            let varsubst = varname
        elseif kind == 'closure' && get(expr_scope,'use_version',0) < 5.026
            let varname  = '$'.varname
            let varsubst = varname . '->()'
        elseif kind == 'closure'
            let varsubst = varname . '()'
        endif
    endif

    " Stop showing the targets (they're about to disappear anyway"
    call matchdelete(multiselect)

    " Prevent inserted lines from wrapping (badly)...
    let textwidth = &textwidth
    let &textwidth = 1000000

    " Replace each target with the hoist variable...
    exec "silent :%s/" . expr_scope['matchloc'] . '/' . varsubst .  "/"

    " Go to the most logical place and insert the hoist variable's definition...
    exec "?" . expr_scope['firstloc']
    if kind == 'variable'
        exec "silent normal Omy " . varname . " = " . expr_scope['target'] . ";\<ESC>V"
    elseif kind == 'closure'
        if get(expr_scope,'use_version',0) < 5.026
            exec "silent normal Omy " . varname . " = sub { " . expr_scope['target'] . " };\<ESC>V"
        else
            exec "silent normal Omy sub " . varname . " { " . expr_scope['target'] . " }\<ESC>V"
        endif
    endif

    " Leave the campsite exactly as we found it...
    let &textwidth = textwidth
endfunction

function! PerlART_matchadd (group, pattern, priority, ...) abort
    call PerlART_matchclear(a:group)
    let b:PerlART_matchID[a:group] =
    \   a:0 > 1 ? matchadd(a:group, a:pattern, a:priority, a:1, a:2)
    \ : a:0 > 0 ? matchadd(a:group, a:pattern, a:priority, a:1)
    \ :           matchadd(a:group, a:pattern, a:priority)
endfunction

function! PerlART_matchclear (group) abort
    if !has_key(b:,'PerlART_matchID')
        let b:PerlART_matchID = {}
    endif
    if has_key(b:PerlART_matchID, a:group)
        try | call matchdelete(b:PerlART_matchID[a:group]) | catch /./ | endtry
    endif
endfunction

function! PerlART_RunCodeAnalysis () abort
    " Kill any incomplete analysis...
    if has_key(b:,'PerlART_RCA_job')
        call job_stop(b:PerlART_RCA_job)
    endif

    " Start a new analysis...
    let b:PerlART_RCA_job
        \ = job_start(['perl', '-MCode::ART::API::Vim', '-E', 'analyze_code()'],
                      \{"in_io" : "buffer", "in_name" : "%", "out_cb": "PerlART_HandleCodeAnalysis"})
endfunction

function! PerlART_HandleCodeAnalysis (channel, msg)
    let b:PerlART_tick = b:changedtick
    let b:PerlART_analysis = eval(a:msg)
    if has_key(b:PerlART_analysis, 'failed')
        return
    endif

    if b:PerlART_analysis['cacograms'] != ''
        call PerlART_matchadd('PerlART_Cacograms',      b:PerlART_analysis['cacograms'],     -2)
    else
        call PerlART_matchclear('PerlART_Cacograms')
    endif
    if b:PerlART_analysis['undeclared_vars'] != ''
        call PerlART_matchadd('PerlART_Undeclared', b:PerlART_analysis['undeclared_vars'], -1)
    else
        call PerlART_matchclear('PerlART_Undeclared')
    endif
    if b:PerlART_analysis['unused_vars'] != ''
        call PerlART_matchadd('PerlART_Unused',     b:PerlART_analysis['unused_vars'],     -1)
    else
        call PerlART_matchclear('PerlART_Unused')
    endif
endfunc


"=====[ Utility function for cmdline interaction ]===========

" Default highlight groups
highlight default AskPrompt  ctermfg=white cterm=bold
highlight default AskDefault ctermfg=blue  cterm=bold,italic
highlight default AskInput   ctermfg=cyan

" Get a character, ignoring annoying timeouts...
function! s:active_getchar () abort

    " Is there anything to get...
    let char = getchar()

    " Skip any CursorHold timeouts, by rechecking...
    while char == "\<CursorHold>"
      let char = getchar()
    endwhile

    " Translate <DELETE>'s...
    if char == 128 || char == "\<BS>"
        return "\<BS>"
    endif

    " See if we got a single character, otherwise return the lot...
    let single_char = nr2char(char)
    return empty(single_char) ? char : single_char
endfunction

" Like the built-in input() function, only prettier and smarter...
function! Ask (prompt, ...) abort
    " Remember where we parked...
    call inputsave()

    " Clean up the prompt...
    let preprompt = split(substitute(a:prompt, '\s*$', ' ', ''), "\n", 1)
    let prompt = remove(preprompt, -1)
    let default = get(a:000,0,'')

    " Echo it, with any default in a different colour
    echohl AskPrompt
    for line in preprompt
        echo line
    endfor

    echohl AskDefault
    echo prompt . default
    echohl AskPrompt
    echon "\r" . prompt
    echohl NONE
    let first = 1
    let input = ''
    while 1
        let next_char = s:active_getchar()
        if first
            echohl AskPrompt
            echon "\r" . prompt . repeat(' ', strchars(default))
            echon "\r" . prompt
            echohl NONE
            let first = 0
        endif
        if next_char == "\<ESC>" || next_char == "\<C-C>"
            call inputrestore()
            return next_char
        elseif next_char == "\<BS>"
            let input = strpart(input,0,strchars(input)-1)
            echohl AskPrompt
            echon "\r" . prompt
            echohl AskInput
            echon input . ' '
            echohl NONE
        elseif next_char == "\<CR>"
            call inputrestore()
            return (strchars(input) ? input : default)
        else
            let input .= next_char
        endif

        " Redraw default if no input...
        if strchars(input) == 0
            echohl AskDefault
            echon "\r" . prompt . default
        endif

        " Redraw prompt and any input...
        echohl AskPrompt
        echon "\r" . prompt
        if strchars(input) > 0
            echohl AskInput
            echon input
        endif
        echohl NONE
    endwhile
endfunction



" Restore previous external compatibility options
let &cpo = s:save_cpo

