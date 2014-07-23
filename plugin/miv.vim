" Vim global plugin for file metadata in Vim 
" Last change:  Sun Apr  4 15:19:55 PDT 2010
" Maintainer:   Damian Conway
" License:  This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_MIV")
    finish
endif
let loaded_MIV = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Implementation starts here...

" Locate metadata directory and ensure it exists...
let s:METADATA_DIR = expand("~/.vim/MIV/metadata")

" Set up handlers for various events...

augroup MIV
    autocmd!

    " starting to edit a new buffer, after reading the file
    autocmd BufNewFile,BufReadPost  *     call MIV_load_metadata_for(expand("%:p"))

    " after writing the whole (or part of) buffer to a file
    autocmd BufWritePost,FileWritePost,FileAppendPost,BufUnload  *     call MIV_save_metadata_for(expand("%:p"))

    " after changing the name of the current buffer
    " (saves old buffer's metadata to new buffer as well)
    autocmd BufFilePre  *    call MIV_save_metadata_for(expand("%:p"))
    
augroup END

function! s:remove_path (filepath) 
    let filepath = a:filepath
    call delete(filepath)
    let shell_failed = 0
    while !shell_failed
        let filepath = fnamemodify(filepath, ':h')
        call system('rmdir ' . filepath)
        let shell_failed = v:shell_error
    endwhile
endfunction


function! MIV_load_metadata_for (filename)
    let metafile = s:METADATA_DIR . a:filename
    if strlen(findfile(metafile, '.'))
        exec 'source ' . metafile
    else
        let b:metadata = {}
    endif
endfunction

function! MIV_save_metadata_for (filename, ...)
    " No metadata for directories we may happen to edit...
    if isdirectory(a:filename)
        return
    endif

    " Otherwise, work out what the metadata consists of...
    let data = a:0                  ? a:1
           \ : exists('b:metadata') ? b:metadata
           \ :                        {}

    " Then work out where it's to be stored...
    let metafile = s:METADATA_DIR . a:filename
    let metadir  = fnamemodify(metafile, ':h')

    " Then work out IF it's to be stored...
    if !empty(data) 
        if !isdirectory(metadir)
            call mkdir(metadir, "p", 0700)
        endif
        call writefile(['let b:metadata = ' . string(data)], metafile)

    else " any residual metadata is to be deleted...
        call s:remove_path(metafile)
    endif
endfunction

" Look through metadata files and cull any for which the corresponding
" realfile no longer exists...
function! MIV_cleanup () 
    " Build the list of metadata files and their corresponding realfiles...
    let METADATA_DIR_len = strlen(s:METADATA_DIR)
    let metafiles = filter(split(glob( s:METADATA_DIR . '/**' )), '!isdirectory(v:val)')
    let realfiles = map(copy(metafiles), 'strpart(v:val,METADATA_DIR_len)')

    " Step through the list, and check that the realfile still exists...
    while len(metafiles)
        let metafile = remove(metafiles, 0)
        let realfile = remove(realfiles, 0)
        if !strlen(glob(realfile))
            call s:remove_path(metafile)
        endif
    endwhile
endfunction


" Restore previous external compatibility options
let &cpo = s:save_cpo
