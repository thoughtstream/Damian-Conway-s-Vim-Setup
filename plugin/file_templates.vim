" Vim global plugin for loading dynamic file skeletons for empty files
"
" Last change:  Mon Jul 24 04:03:59 AEST 2017
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.
"
" NOTE: Requires Vim 8.0 or better

" If already loaded, we're done...
if exists("loaded_file_templates")
    finish
endif
let loaded_file_templates = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" =====[ Documentation ]============================
"
" Looks in the specified directory for template files named
" template.<extension>. For example:
"
"     > ls ~/.vim_templates/
"     template.c
"     template.h
"     template.pl
"     template.pm
"     template.py
"     template.t
"
" Grabs the template with the same extension as the file you're
" creating, replaces any <PLACEHOLDER> it recognizes in the text
" with suitable data, then fills the empty buffer of the new file
" with the filled-in template text.
"
" You can add extra template data as a dictionary stored in the
" g:FileTemplatesInfo variable (you should probably set up
" this variable in your .vimrc). For example to add data for
" new <NAME> and <ADDR> template placeholders:
"
"     let g:FileTemplatesInfo = {
"     \        'NAME'  : 'S. Holmes',
"     \        'ADDR'  : '221b Baker St'
"     \}
"

"=====[ API ]==============================

" Change this to change were your file templates are stored...
let s:TEMPLATE_DIR = '~/.vim_templates/'

" This sets up the event handlers for new files...
augroup FileTemplates
    autocmd!
    autocmd BufNewFile   *  :call FindAndFillTemplate(expand('<afile>:p'))
    autocmd BufNewFile   *  :silent call search('^[ \t]*[#"].*implementation[ \t]\+here')
    autocmd BufNewFile   *  :redraw
augroup END


"=====[ Implementation ]==============================

function! FindAndFillTemplate (filepath) abort

    " Build a Perl module name from the filename...
    let modname = fnamemodify(a:filepath, ":r")
    let modname = substitute(modname, '/', '::', 'g')
    let modname = substitute(modname, '^.*::lib::', '', '')
    let modname = substitute(modname, '^lib::', '', '')

    " Build a Perl RT address from the filename...
    let rtname = fnamemodify(a:filepath, ":r")
    let rtname = substitute(rtname, '/', '-', 'g')
    let rtname = substitute(rtname, '^.*-lib-', '', '')
    let rtname = substitute(rtname, '^lib-', '', '')

    " Construct other information to replace placeholders in the template...
    let REPLACEMENTS = {
    \   'FILENAME'    : fnamemodify(a:filepath, ':t'),
    \   'FILEROOT'    : fnamemodify(a:filepath, ':t:r'),
    \   'TIMESTAMP'   : strftime("%FT%T%z"),
    \   'DATE'        : strftime("%c"),
    \   'YEAR'        : strftime("%Y"),
    \   'MODULE NAME' : modname,
    \   'RT NAME'     : tolower(rtname)
    \}

    " Add in user-defined information from g:FileTemplatesInfo (if any)...
    call extend(REPLACEMENTS, get(g:, 'FileTemplatesInfo', {}))

    " Locate and read in the relevant template file...
    let extension = fnamemodify(a:filepath, ':e')
    if filereadable(expand(s:TEMPLATE_DIR) . 'template.' . extension)
        let template = join( readfile(expand(s:TEMPLATE_DIR) . 'template.' . extension), "\n" )

        " Replace all the placeholders...
        let template 
        \   = substitute(template, '<\([A-Z_ ]\+\)>', { m -> get(REPLACEMENTS, m[1], m[0]) }, 'g')

        " Install the filled-in template into the empty buffer...
        call append(0, split(template, "\n"))
    endif
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo


