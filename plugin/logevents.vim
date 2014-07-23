" Vim global plugin for LogEvents
" Last change:  LogEvents
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_LogEvents")
    finish
endif
let loaded_LogEvents = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Is this thing on???
let s:show_events  = 0
let s:start_time   = reltime()
let s:first_report = 1

function! s:ReportEvent (eventtype, filename)
    if s:first_report && expand('%:t') != 'events.log'
        redir! > ~/.vim/events.log
        let s:first_report = 0
    endif
    redir! >> ~/.vim/events.log
    echomsg '[' . substitute(reltimestr(reltime(s:start_time)),'^\s*','','') . ']'   a:eventtype   a:filename
    redir END
endfunction

function! LogEvents_Toggle ()
    let s:show_events = !s:show_events
    echo "[Event reporting:" s:show_events ? "on]" : "off]"
    augroup LogEvents
        au!
        if s:show_events
            au BufAdd                 *   silent call <SID>ReportEvent("BufAdd/BufCreate",expand("<amatch>:t"))
            au BufDelete              *   silent call <SID>ReportEvent("BufDelete",expand("<amatch>:t"))
            au BufEnter               *   silent call <SID>ReportEvent("BufEnter",expand("<amatch>:t"))
            au BufFilePost            *   silent call <SID>ReportEvent("BufFilePost",expand("<amatch>:t"))
            au BufFilePre             *   silent call <SID>ReportEvent("BufFilePre",expand("<amatch>:t"))
            au BufHidden              *   silent call <SID>ReportEvent("BufHidden",expand("<amatch>:t"))
            au BufLeave               *   silent call <SID>ReportEvent("BufLeave",expand("<amatch>:t"))
            au BufNew                 *   silent call <SID>ReportEvent("BufNew",expand("<amatch>:t"))
            au BufNewFile             *   silent call <SID>ReportEvent("BufNewFile",expand("<amatch>:t"))
            au BufRead                *   silent call <SID>ReportEvent("BufRead[Post]",expand("<amatch>:t"))
            au BufReadCmd             *   silent call <SID>ReportEvent("BufReadCmd",expand("<amatch>:t"))
            au BufReadPre             *   silent call <SID>ReportEvent("BufReadPre",expand("<amatch>:t"))
            au BufUnload              *   silent call <SID>ReportEvent("BufUnload",expand("<amatch>:t"))
            au BufWinEnter            *   silent call <SID>ReportEvent("BufWinEnter",expand("<amatch>:t"))
            au BufWinLeave            *   silent call <SID>ReportEvent("BufWinLeave",expand("<amatch>:t"))
            au BufWipeout             *   silent call <SID>ReportEvent("BufWipeout",expand("<amatch>:t"))
            au BufWrite               *   silent call <SID>ReportEvent("BufWrite[Pre]",expand("<amatch>:t"))
            au BufWriteCmd            *   silent call <SID>ReportEvent("BufWriteCmd",expand("<amatch>:t"))
            au BufWritePost           *   silent call <SID>ReportEvent("BufWritePost",expand("<amatch>:t"))
            au CmdwinEnter            *   silent call <SID>ReportEvent("CmdwinEnter",expand("<amatch>:t"))
            au CmdwinLeave            *   silent call <SID>ReportEvent("CmdwinLeave",expand("<amatch>:t"))
            au ColorScheme            *   silent call <SID>ReportEvent("ColorScheme",expand("<amatch>:t"))
            au CursorHold             *   silent call <SID>ReportEvent("CursorHold",expand("<amatch>:t"))
            au CursorHoldI            *   silent call <SID>ReportEvent("CursorHoldI",expand("<amatch>:t"))
            au CursorMoved            *   silent call <SID>ReportEvent("CursorMoved",expand("<amatch>:t"))
            au CursorMovedI           *   silent call <SID>ReportEvent("CursorMovedI",expand("<amatch>:t"))
            au EncodingChanged        *   silent call <SID>ReportEvent("EncodingChanged",expand("<amatch>:t"))
            au FileAppendCmd          *   silent call <SID>ReportEvent("FileAppendCmd",expand("<amatch>:t"))
            au FileAppendPost         *   silent call <SID>ReportEvent("FileAppendPost",expand("<amatch>:t"))
            au FileAppendPre          *   silent call <SID>ReportEvent("FileAppendPre",expand("<amatch>:t"))
            au FileChangedRO          *   silent call <SID>ReportEvent("FileChangedRO",expand("<amatch>:t"))
            au FileChangedShell       *   silent call <SID>ReportEvent("FileChangedShell",expand("<amatch>:t"))
            au FileChangedShellPost   *   silent call <SID>ReportEvent("FileChangedShellPost",expand("<amatch>:t"))
            au FileReadCmd            *   silent call <SID>ReportEvent("FileReadCmd",expand("<amatch>:t"))
            au FileReadPost           *   silent call <SID>ReportEvent("FileReadPost",expand("<amatch>:t"))
            au FileReadPre            *   silent call <SID>ReportEvent("FileReadPre",expand("<amatch>:t"))
            au FileType               *   silent call <SID>ReportEvent("FileType",expand("<amatch>:t"))
            au FileWriteCmd           *   silent call <SID>ReportEvent("FileWriteCmd",expand("<amatch>:t"))
            au FileWritePost          *   silent call <SID>ReportEvent("FileWritePost",expand("<amatch>:t"))
            au FileWritePre           *   silent call <SID>ReportEvent("FileWritePre",expand("<amatch>:t"))
            au FilterReadPost         *   silent call <SID>ReportEvent("FilterReadPost",expand("<amatch>:t"))
            au FilterReadPre          *   silent call <SID>ReportEvent("FilterReadPre",expand("<amatch>:t"))
            au FilterWritePost        *   silent call <SID>ReportEvent("FilterWritePost",expand("<amatch>:t"))
            au FilterWritePre         *   silent call <SID>ReportEvent("FilterWritePre",expand("<amatch>:t"))
            au FocusGained            *   silent call <SID>ReportEvent("FocusGained",expand("<amatch>:t"))
            au FocusLost              *   silent call <SID>ReportEvent("FocusLost",expand("<amatch>:t"))
            au FuncUndefined          *   silent call <SID>ReportEvent("FuncUndefined",expand("<amatch>:t"))
            au GUIEnter               *   silent call <SID>ReportEvent("GUIEnter",expand("<amatch>:t"))
            au InsertChange           *   silent call <SID>ReportEvent("InsertChange",expand("<amatch>:t"))
            au InsertEnter            *   silent call <SID>ReportEvent("InsertEnter",expand("<amatch>:t"))
            au InsertLeave            *   silent call <SID>ReportEvent("InsertLeave",expand("<amatch>:t"))
            au MenuPopup              *   silent call <SID>ReportEvent("MenuPopup",expand("<amatch>:t"))
            au QuickFixCmdPost        *   silent call <SID>ReportEvent("QuickFixCmdPost",expand("<amatch>:t"))
            au QuickFixCmdPre         *   silent call <SID>ReportEvent("QuickFixCmdPre",expand("<amatch>:t"))
            au RemoteReply            *   silent call <SID>ReportEvent("RemoteReply",expand("<amatch>:t"))
            au SessionLoadPost        *   silent call <SID>ReportEvent("SessionLoadPost",expand("<amatch>:t"))
            au ShellCmdPost           *   silent call <SID>ReportEvent("ShellCmdPost",expand("<amatch>:t"))
            au ShellFilterPost        *   silent call <SID>ReportEvent("ShellFilterPost",expand("<amatch>:t"))
            au SourcePre              *   silent call <SID>ReportEvent("SourcePre",expand("<amatch>:t"))
            au SpellFileMissing       *   silent call <SID>ReportEvent("SpellFileMissing",expand("<amatch>:t"))
            au StdinReadPost          *   silent call <SID>ReportEvent("StdinReadPost",expand("<amatch>:t"))
            au StdinReadPre           *   silent call <SID>ReportEvent("StdinReadPre",expand("<amatch>:t"))
            au SwapExists             *   silent call <SID>ReportEvent("SwapExists",expand("<amatch>:t"))
            au Syntax                 *   silent call <SID>ReportEvent("Syntax",expand("<amatch>:t"))
            au TabEnter               *   silent call <SID>ReportEvent("TabEnter",expand("<amatch>:t"))
            au TabLeave               *   silent call <SID>ReportEvent("TabLeave",expand("<amatch>:t"))
            au TermChanged            *   silent call <SID>ReportEvent("TermChanged",expand("<amatch>:t"))
            au TermResponse           *   silent call <SID>ReportEvent("TermResponse",expand("<amatch>:t"))
            au User                   *   silent call <SID>ReportEvent("User",expand("<amatch>:t"))
            au VimEnter               *   silent call <SID>ReportEvent("VimEnter",expand("<amatch>:t"))
            au VimLeave               *   silent call <SID>ReportEvent("VimLeave",expand("<amatch>:t"))
            au VimLeavePre            *   silent call <SID>ReportEvent("VimLeavePre",expand("<amatch>:t"))
            au VimResized             *   silent call <SID>ReportEvent("VimResized",expand("<amatch>:t"))
            au WinEnter               *   silent call <SID>ReportEvent("WinEnter",expand("<amatch>:t"))
            au WinLeave               *   silent call <SID>ReportEvent("WinLeave",expand("<amatch>:t"))
        endif
    augroup END
endfunction

nmap <silent> ;e :call LogEvents_Toggle()<CR>

" Restore previous external compatibility options
let &cpo = s:save_cpo
