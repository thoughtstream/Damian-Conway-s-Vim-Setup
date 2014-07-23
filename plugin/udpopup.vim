" Vim global plugin for simulating user-defined popup menus
" Version:       0.0.1_b2
" Status:        Beta, unsupported
" Last change:   Mon May  5 14:43:09 EST 2008
" Maintainer:	 Damian Conway
" Copyright:     (c) 2008, Damian Conway. All Rights Reserved.
" Licence:       This is free software licensed under the Artistic License 2.0
" Documentation: See after the second 'finish' below

" If already loaded, we're done...
if exists("loaded_udpopup")
  finish
endif
let loaded_udpopup = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Default colours for popup components...
highlight UDPshadow_light    ctermbg=black   ctermfg=blue
\                            term=NONE
highlight UDPitem_light      ctermbg=black   ctermfg=white
\                            term=inverse
highlight UDPtitle_light     ctermbg=black   ctermfg=white  cterm=bold
\                            term=bold
highlight UDPselection_light ctermbg=blue    ctermfg=white  cterm=bold
\                            term=inverse,bold

highlight UDPshadow_dark     ctermbg=black   ctermfg=blue
\                            term=NONE
highlight UDPitem_dark       ctermbg=white   ctermfg=black
\                            term=inverse
highlight UDPtitle_dark      ctermbg=white   ctermfg=black  cterm=bold
\                            term=bold
highlight UDPselection_dark  ctermbg=blue    ctermfg=white  cterm=bold
\                            term=inverse,bold

" Build a regex that matches the specified region...
function! s:match (rowstart, rowwidth, colstart, colwidth, ...)
    let prematch = a:0 ? a:1 : ""
    let matchpat = s:match_pat(a:rowstart,a:rowwidth,a:colstart,a:colwidth)
    return prematch . matchpat
endfunction

function! s:match_pat (rowstart, rowwidth, colstart, colwidth)
    let rowto   = max([a:rowstart+a:rowwidth,0])
    let rowfrom = max([a:rowstart-1,0])
    let colto   = max([a:colstart+a:colwidth,0])
    let colfrom = max([a:colstart-1,0])
    return '\%>'.rowfrom.'l\%<'.rowto.'l\%>'.colfrom.'c\%<'.colto.'c' 
endfunction

" Show a popup containing the specified values...
function! UDPopup (popup_values, ...)
    " Convert item sequence to list...
    if type(a:popup_values) == type({})
        let popup_values = sort(keys(a:popup_values))

    elseif type(a:popup_values) == type("")
        let popup_values = split(a:popup_values, "\n")

    else
        let popup_values = a:popup_values
    endif

    " Extract options dictionary (if any)...
    let opt = a:0 ? a:1 : {}

    " Extract any response handlers...
    let on_response = get(opt, 'keys', {})

    " Save windowsposition (which the later delete will reset)...
    let saved_window = winsaveview()
    let win_height   = winheight(0)
    let win_width    = winwidth (0)
    let buf_win_top  = saved_window.topline
    let buf_win_left = saved_window.leftcol
    let win_cur_row  = saved_window.lnum - buf_win_top + 1
    let win_cur_col  = saved_window.col - buf_win_left + 1

    " Internally snapshot buffer contents and cursor location...
    let buf_state = getline(1,'$')
    let [buf_cur_row, buf_cur_col, buf_cur_offset] = getpos('.')[1:3]

    " Locate where we are to draw popup, or default to cursor position...
    let popup_pos   = get(opt, 'pos', [])
    let win_pop_row = len(popup_pos) ? popup_pos[0] : win_cur_row
    let win_pop_col = len(popup_pos) ? popup_pos[1] : win_cur_col

    " If requested positions start with +/-, make them relative to cursor...
    let win_pop_row
    \   = win_pop_row =~ '^[-+]' ? eval(win_cur_row . win_pop_row) : win_pop_row
    let win_pop_col
    \   = win_pop_col =~ '^[-+]' ? eval(win_cur_col . win_pop_col) : win_pop_col

    " Create buffer-relative equivalents...
    let buf_pop_row = win_pop_row + buf_win_top - 1
    let buf_pop_col = win_pop_col + buf_win_left

    " Detect user-defined selection keys...
    let has_selectkeys = match(popup_values, '\%>1c&') >= 0

    " Size of popup (width+2/5 to allow visual space at edges of popup)...
    let popup_width = max(map(copy(popup_values),'strlen(v:val)'))
                  \ + (has_selectkeys ? 5 : 0)
    let popup_height = len(popup_values)

    " Is there a title?
    if has_key(opt,'title')
        " Extend the popup dimensions and data...
        let title_lines  = split(opt.title, "\n")
        let title_width  = max(map(copy(title_lines), 'strlen(v:val)'))
        let popup_width  = max([title_width, popup_width])
        let popup_values = title_lines + popup_values
        let popup_height += len(title_lines)
        let has_title    = len(title_lines)
    else
        let popup_values = popup_values
        let has_title    = 0
    endif

    " Allow for 1-char side borders in popup...
    let popup_width += 2

    " If too little space for popup, adjust popup position appropriately...
    let max_popup_height = win_height - win_pop_row
    if max_popup_height < popup_height
        let win_pop_row = max([1,win_height-popup_height+1])
        let buf_pop_row = win_pop_row + buf_win_top - 1
    endif
    let max_popup_width = win_width - win_pop_col
    if max_popup_width < popup_width
        let win_pop_col = max([1,win_width-popup_width+1])
        let buf_pop_col = win_pop_col + buf_win_left - 1
    endif

    " Preserve tab settings (and hide new tab if possible)...
    let prev_showtabline = &showtabline
    let prev_tabline = &tabline
    let prev_list = &list
    if &showtabline < 2 && tabpagenr('$') == 1
        let &showtabline = 0
    endif

    " Prepare to copy syntax highlighting settings...
    let curr_syntax = &syntax
    
    " Open a new tab in which to display the menu...
    tabnew

    " Prime the buffer with a detabbed copy of the text...
    call setline(1,buf_state)
    set expandtab
    %retab!

    " Make a copy to use as a background for the popup...
    let buffer_copy = getline(1,'$')


    " Minimize tab label changes and use identical syntax highlighting...
    let &tabline = 'MENU'
    let &syntax = curr_syntax

    " Make sure spaces in the menu aren't shown...
    let &list = 0

    " Set colours according to background type (light or dark)...
    for hl in ['UDPtitle', 'UDPshadow', 'UDPselection', 'UDPitem']
        exe printf('highlight! link %s %s_%s',hl,hl,&background)
    endfor

    " Create new match behaviours to colour the popup...
    let popup_matches
    \    = [matchadd('UDPitem', s:match(buf_pop_row+has_title, popup_height-has_title, buf_pop_col, popup_width))]
    let popup_matches
    \   += (has_title ? [matchadd('UDPtitle', s:match(buf_pop_row, has_title, buf_pop_col, popup_width))] : [])
    let popup_matches
    \   += [matchadd('UDPshadow', s:match(buf_pop_row, popup_height+1, buf_pop_col-1, popup_width+2),1)]


    " Create and run the simulated popup...
    try
        let list_selector_row = -1
        let enabled = []
        let selectkeys = {}
        let list_row = max([buf_pop_row-1,0])
        let list_col = max([buf_pop_col-1,0])

        " Copy lines from buffer, overwriting with the popup content...
        for n in range(len(popup_values))
            let item = popup_values[n]

            " Items consisting only of '___' or '|', are extended to full width
            if item =~ '^_\+$' || item == '|'
                let item = repeat('_',popup_width-2)
            endif

            " Remember which items are disabled (and the first enabled one)...
            let enabled += [ n >= has_title && item !~ '^_\+$\|^(.*)$' ]
            let list_selector_row = list_selector_row < 0 && enabled[-1]
            \                           ? len(enabled)-1
            \                           : list_selector_row

            " A & marks the next letter as a selectkey (i.e. a valid response)
            let selectkey = " "
            let has_selectkey = 0
            if enabled[-1] && item =~ '&[^&]' && n >= has_title
                let match = matchlist(item, '\(.*\)&\([^&]\)')
                let selectkey = match[2]
                if !has_key(selectkeys, selectkey)
                    let selectkeys[selectkey] = len(enabled) - has_title - 1
                    let has_selectkey = enabled[-1] && n >= has_title
                endif
            endif

            " Selector at the start is (sometimes) a special case...
            let has_selectkey = has_selectkey && item !~ '^&.[[:punct:][:space:]]'

            " Remove the selector marker...
            let item = substitute(item, '&\(.\)', '\1', 'g')

            " Extend the buffer, if necessary...
            if list_row >= len(buffer_copy)
                let buffer_copy += [ "" ]
            endif

            " Overwrite each buffer line with the popup lines...
            let buffer_copy[list_row] = printf('%-*s%-*s%s%s',
            \   list_col, strpart(buffer_copy[list_row],0,list_col),
            \   (has_selectkey ? popup_width-5 : popup_width),  " ".item." ",
            \   (has_selectkey ? " [".selectkey."] " : ""),
            \   strpart(buffer_copy[list_row],list_col+popup_width)
            \)

            let list_row += 1
        endfor

        " Make user-defined keys case-insensitive where possible...
        for key in keys(selectkeys)
            if !has_key(selectkeys, tolower(key))
                let selectkeys[tolower(key)] = selectkeys[key]
            endif
            if !has_key(selectkeys, toupper(key))
                let selectkeys[toupper(key)] = selectkeys[key]
            endif
        endfor
    
        " Is everything disabled?
        if list_selector_row < 0
            return {
            \   'failed':   1,
            \   'status':  'No selectable items',
            \   'selected': 0,
            \   'index':   -1,
            \   'value':   "",
            \   'input':    "",
            \}
        endif

        " Replace the buffer with the overdrawn copy...
        1,$delete
        call setline(1,buffer_copy)

        " Reinstate cursor within window after buffer copy drawn...
        call cursor(buf_cur_row, buf_cur_col, buf_cur_offset)
        call winrestview(saved_window)
        redraw

        " Where to start scrolling a long popup...
        let buf_pop_scroll_row = buf_pop_row + win_height - 1 - &scrolloff

        " Handle user interactions with popup
        let popup_matches += [0]
        while 1
            " Prompt...
            if popup_matches[-1] > 0
                call matchdelete(popup_matches[-1])
            endif
            let popup_matches[-1]
            \    = matchadd('UDPselection', s:match(buf_pop_row+list_selector_row, 1, buf_pop_col, popup_width))
            redraw

            " Decode response...
            let response = getchar()
            let response = response =~ '^\d\+$' ? nr2char(response) : response
            undojoin

            " Translate command if possible...
            let command = get(on_response, response, response)

            if has_key(selectkeys, command)
                return {
                \   'status':    "Selected by key",
                \   'input':     response,
                \   'selected':  1,
                \   'index':     selectkeys[command],
                \   'value':     popup_values[selectkeys[command] + has_title],
                \   'failed':    0,
                \}

            elseif command == "\<Down>"
          \ || command =~ '\cDOWN\|\cTAB'
          \ || command == "\t"
                while 1
                    let list_selector_row = list_selector_row >= popup_height-1
                    \                           ? 0
                    \                           : list_selector_row + 1
                    if enabled[list_selector_row]
                        break
                    endif
                endwhile

            elseif command == "\<Up>"
            \   || command == "\<S-Tab>"
            \   || command =~ '\cUP\|\cSTAB'
                while 1
                    let list_selector_row = list_selector_row <= 0
                    \                           ? popup_height-1
                    \                           : list_selector_row - 1
                    if enabled[list_selector_row]
                        break
                    endif
                endwhile

            elseif command == "\<C-C>"
            \   || command =~ '\cESC\|\cCC'
            \   || command == "\e"
                return {
                \   'failed':    1,
                \   'status':   'Cancelled',
                \   'index':     -1,
                \   'value':     "",
                \   'input':     response,
                \   'selected':  0,
                \}

            elseif command == "\r"
            \   || command == "\n"
            \   || command =~ '\cNL\|\cCR'
                return {
                \   'status':    "Selected by position",
                \   'index':     list_selector_row - has_title,
                \   'selected':  1,
                \   'value':     popup_values[list_selector_row],
                \   'input':     response,
                \   'failed':    0,
                \}

            endif

            " Scroll window to track selection (if necessary)...
            let windata = copy(saved_window)
            let scroll_row = windata.topline + win_height - &scrolloff - 2
                              " -2 because deltas are always diff-1:   - 1
                              "             plus list is zero based:   - 1
            if list_selector_row >= scroll_row
                let scroll = list_selector_row - scroll_row
                let windata.topline += scroll
                let windata.lnum += scroll
            endif
            call winrestview(windata)
        endwhile

    finally
        " Restore tab labels...
        let &tabline     = prev_tabline
        let &showtabline = prev_showtabline
        let &list        = prev_list

        " Restore matches
        for matcher in popup_matches
            call matchdelete(matcher)
        endfor

        " Replace cursor...
        quit!
        echo " "
        redraw
    endtry
endfunction

" Restore previous external compatibility options
let &cpo = s:save_cpo

finish
##############################################################################

=pod

=head1 NAME

udpopup.vim - Simulate a user-defined popup menu


=head1 VERSION

This documentation refers to udpopup.vim version 0.0.1_b


=head1 USAGE

    :let result = UDPopup(item_list)

    :let result = UDPopup(item_list, opt_dict)


=head1 REQUIRED ARGUMENTS

=over

=item C<item_list>

C<UDPopup()> expects a single argument, which must specify a sequence of items
that are to appear in the popup. The items argument may be either a list, a
string, or a dictionary (see L<"Invoking a popup">).

=back


=head1 OPTIONS

You can also pass a second argument, which must be a dictionary.
The entries in this dictionary can be used to specify the following options:

=over

=item C<'title': "popup_title">

This option specifies that the popup has a title. See L<"Titles">.


=item C<'pos': [row, col]>

This option specifies where the popup will appear. See L<"Manual placement">


=item C<'keys': {'a': "action", 'b': "action",...}>

This option allows you to specify one or more keys that can be pressed when
the popup is active. See L<"User-defined keys">

=back


=head1 FEATURES

=head2 Invoking a popup

This plugin provides a single public function, C<UDPopup()>.

That function takes one or two arguments: a sequence of items to display
in the popup, and an optional dictionary specifying configuration
options for the popup. The items may be specified either as a list of
strings, or as a dictionary (in which the sorted keys are the items), or
as a single string (in which the items are separated by newlines).

The function displays the sequence of items, one per line, and allows
the user either to select one or to cancel the popup without selecting.
It then returns a dictionary indicating what (if anything) was selected.

For a simple popup, displayed at the cursor position, no options are required,
so the typical usage is something like:

    let recreation = UDPopup(['Eat?','Drink?','Be merry?'])

    let filename = UDPopup(glob('*.txt'))

    let lexicon = UDPopup(languages_dict)

Options modifying the standard popup behaviour are specified in a
dictionary, passed as an additional argument:

    let recreation = UDPopup(['Eat','Drink','Be merry'],{'title':'Do what?'})

    let filename = UDPopup(glob('*.txt'), {'pos':[1,1]})

    let lexicon = UDPopup(language_dict, { 'keys': {'x': 'ESC'} }) 


=head2 Interacting with a popup

Once the popup is active, you can use the following standard keys
to control it:

    <Down> or <Tab>        Highlight the next item

      <Up> or <S-Tab>      Highlight the previous item

      <NL> or <LF>         Select the currently highlighted item

     <Esc> or <C-C>        Cancel the popup without selecting


=head2 Return values

The C<UDPopup()> function always returns a dictionary with the
following keys defined:

=over

=item C<'index'>

A number that is the (zero-based) ordinal position of the selected item
within the popup list. Will be -1 if the popup was cancelled or failed.


=item C<'value'>

A string containing the actual text of the item that was selected.
Will be an empty string if the popup was cancelled or failed.


=item C<'input'>

A one-character string containing the key that the user entered to
complete the popup. Typically will be C<< "\n" >> or C<< "\e" >>, but
may also be a user-defined key (see L<"User-defined keys">).
Will be an empty string if the popup was cancelled or failed.


=item C<'selected'>

The number of items selected. In the current version of the plugin this
value is always either 1 (if the popup completed successfully and
returned a selection) or zero (if the popup failed and did not return a
selection).


=item C<'failed'>

A boolean value that is true if the popup was cancelled by the user,
or couldn't be displayed at all for some reason. Always equal to
C<!result.selected>


=item C<'status'>

A string containing a diagnostic explaining how and why the popup terminated
(see L<"DIAGNOSTICS">)

=back

Every return value always contains all these keys, so they can be safely
accessed using the "dot" notation, without bothering to check first for
their existence. For example:

    let filename = UDPopup( glob('./*.txt'), {'title': getcwd()} )
    
    if filename.selected
        execute ':next ' . filename.value
    endif


=head2 Autoplacement

By default, the popup appears with its top-left corner at the current
cursor position.

However, if the popup is too long or too wide to fit in the current
window, then the popup will be moved upwards and/or to the left to allow
it to fit.

In extreme cases, the popup may be moved to the very top-left of the
window...and yet still not fully fit. In those cases, the popup will
scroll up and down as necessary.


=head2 Manual placement

You can also indicate that the popup should appear somewhere other than
at the cursor, by specifying the C<'pos'> option.

The value must be an array of two elements, which are treated used as
the C<[line, col]> position for the top-let corner of the popup,
relative to the current window. For example:

    let result = UDPopup(items, {'pos': [winheight(0)/2, winwidth(0)/2]})

causes the top-left corner of the popup to be placed in the middle of the
current window.

If either the row or column value begins with an explicit C<'+'> or
C<'-'>, that ordinate is treated as being relative to the current cursor
position. So, for example:

    :let result = UDPopup(items, { 'pos': [-1,'+1'] })

causes the top-left corner of the popup to be placed one row above and
one column to the right of the current cursor position. When requesting
a positive offset, be sure to quote it (i.e. C<'+1'>, not C<+1>).

Note, however, that the position adjustments to ensure the popup is
maximally on-screen (see L<"Autoplacement">) are still performed
when the position is explicitly specified.

    
=head2 Titles

Any popup can be given a title, by specifying the C<'title'> option:

    :let account = UDPopup(accounts, {'title': "Select account..."})

The title is displayed at the top of the popup using a distinct
highlight group (see L<"CONFIGURATION">).

The title can be made to run across several lines, by including
newlines in it:

    :let result = UDPopup(accounts, {'title': "Please select\nyour account"})

If this option is not specified, the popup is rendered without any title.


=head2 Selector keys

You can associate a specific key with any popup item, by prefixing the
corresponding letter in the item's string with a C<'&'>. For example:

    let action = UDPopup(['&Save','&Delete','Revert','S&wap'])

Note that, when specifying selector keys on one or more popup items, you
don't have to specify selector keys for them all.

When a popup with selector keys is active, the user may press any of
those keys and the corresponding item will immediately be selected and
returned. The selector keys for each item are shown in the popup, to the
right of the item:

      ..............
      : Save     s :
      : Delete   d :
      : Revert     :
      : Swap     w :
      :............:

When the popup is displayed, the C<'&'> characters are removed from the
items, but they are still present in the C<'value'> entry of the
dictionary that is returned:

    let action = UDPopup(['&Save','&Delete','Revert','S&wap'])

    if action.value == 'S&wap'
        call SwapBuffer()
    endif

If the same key is specified for two or more items:

    let action = UDPopup(['&Save','&Delete','Revert','&Swap'])

then the key only applies to the first such item.


=head2 User-defined keys

You can also specify your own keys to perform any of the standard popup
control actions described in L<"Interacting with a popup">, using the
C<'keys'> option.

The value of this option must be a dictionary. The first letter of each
dictionary key is used as a control key while the popup is active. The
effect of pressing that key is specified by the corresponding
value in the dictionary. For example:

    let action = UDPopup(['&Save','&Delete','Revert','S&wap'],
    \                    {'keys': {'q':'ESC', 'j':'DOWN', 'v':'s'} }
    \                   )

In this example, if the user presses the 'q' key during the popup, it
has the same effect as pressing <Esc>. A 'j' has the same effect as a
<Down> or <Tab>, and a 'v' has the same effect as an 's' (i.e.
immediately select and return the C<'&Save'> item)

So the C<'keys'> option allows you to create aliases, both for 
the L<built-in popup control keys|"Interacting with a popup"> and for
any L<user-defined keys|"User-defined keys">

The standard popup controls can be aliased by using the following strings
as values:

     <Down> or <Tab>         'DOWN', 'Down', 'down', 'TAB', 'Tab', 'tab'

       <Up> or <S-Tab>       'UP', 'Up', 'up', 'STAB', 'STab', 'stab'

       <NL> or <CR>          "\n", 'NL', 'Nl', 'nl', "\r", 'CR', 'Cr', 'cr'

      <Esc> or <C-C>         "\e", 'ESC', 'Esc', 'esc', 'CC', 'Cc', 'cc'

Certain other characters are also reserved for future use as
popup controls, namely:

    <Right>
    <Left>
    <Del>
    +
    =
    -  (hyphen)
    _  (underscore)
    |
    \

Using any of these reserved characters as a
L<user-defined key|"User-defined keys">
is not future-compatible and will eventually lead to suffering and regret.


=head2 Disabling items

You can specify items that are to appear in the popup, but which are not
able to be selected. This is useful to keep the layout of a popup
consistent, even though some items are not currently valid choices.

To disable selection on a particular item, surround it with parentheses:

    let action = UDPopup(['&Save','(&Delete)','&Swap','(Revert)'])

The items will be displayed (including the parens), but will not be able to be
selected in any way. If they have a L<selector key|"Selector keys">, it will
not be operational, and will not be displayed.


=head2 Inserting separators between items

Any item string that consists entirely of one or more underscores:

    let command  = UDPopup(['Start','Stop','_','Next','Prev','_','Quit'])

or a single vertical bar:

    let command  = UDPopup(['Start','Stop','|','Next','Prev','|','Quit'])

is treated as a separator, and is displayed in the popup as a full line
of underscores (regardless of how it was actually specified):

       ............
       : Start    :
       : Stop     :
       : ________ :
       : Next     :
       : Previous :
       : ________ :
       : Quit     :
       :..........:

Separator lines cannot be selected within the popup.


=head1 DIAGNOSTICS

All diagnostics are returned in the result dictionary's C<.status> entry.
The possibilities are:

=over

=item C<'No selectable items'>

The popup failed because the total number of selectable items you
specified was zero. Usually this is because you specified an empty item
list, but it may also occur if there are items, but all of them
have been disabled.


=item C<'Cancelled'>

The popup failed because the user pressed C<< <ESC> >> or C<< <CTRL-C> >> or
some equivalent user-defined key, cancelling the popup without having
made a selection.


=item C<'Selected by position'>

The popup succeeded when the user pressed C<< <RET> >> or some equivalent
user-defined key, selecting the currently highlighted item.


=item C<'Selected by key'>

The popup succeeded when user pressed the selector key for an item (see
L<"User-defined keys">), selecting that item. They key they pressed is
available as C<result.key>

=back

A typical usage of the C<'status'> value is:

    let result = UDPopup(items, options)

    if result.failed
        echoerr result.status
    else
        echomsg 'You chose: '.result.value.' ('.result.status.')'
    endif


=head1 INSTALLATION

Place the C<udpopup.vim> file in your Vim C<plugin/> directory.

Typically this is either:

    $VIMRUNTIME/plugin/     to install for all users
    ~/.vim/plugin           to install for this user only


=head1 CONFIGURATION AND ENVIRONMENT

You can configure the colourscheme that C<UDPopup()> uses by redefining 
any of the following highlight groups:

    UDPselection_light      Colour of the currently selected item
    UDPselection_dark       

    UDPitem_light           Colour of all unselected items
    UDPitem_dark            

    UDPtitle_light          Colour of popup title
    UDPtitle_dark           

    UDPshadow_light         Shadow effects for popup
    UDPshadow_dark          

For example:

    " Make popups stark against dark backgrounds
    highlight UDPselection_dark term=bold   ctermbg=red  ctermfg=white
    highlight UDPitem_dark      term=inverse
    highlight UDPtitle_dark     term=inverse,bold
    highlight UDPshadow_dark    term=none

The C<_light> and C<_dark> suffixes allow you to set distinct colorschemes 
depending how the C<'background'> option is set

Note that it is not I<necessary> to configure these highlights;
the defaults are designed to look good and work well in most cases.


=begin TODO

Possible extensions to this plugin.
(None are currently scheduled for implementation though)

=item Add 'autokeys' option to autoassign selector keys

=item Hierarchical items via list elements

=item Configurable hierarchical items via dictionary elements

=item Show disabled items differently (i.e. with separate highlight?)

=item Redo scrolling to apply only to popup (i.e. not entire window)

=item "Anti-keys" to disable specific actions

=item Multiple selections

=end TODO


=head1 AUTHOR

Damian Conway


=head1 COPYRIGHT

Copyright (c) 2008, Damian Conway C<< <DCONWAY@cpan.org> >>. All rights reserved.

This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License 2.0
(see: http://www.perlfoundation.org/artistic_license_2_0)


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
