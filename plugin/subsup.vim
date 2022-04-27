" Vim global plugin for superscripts and subscripts
"
" Last change:  2019-08-15T15:32:27+1000
" Maintainer:   Damian Conway
" License:      This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_subsup")
    finish
endif
let loaded_subsup = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

let s:iso_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890()-+='
let s:sup_chars = 'ᴬᴮ ᴰᴱ ᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾ ᴿˢᵀᵁⱽᵂˣ ᶻªᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖ ʳˢᵗᵘᵛʷˣʸᶻ¹²³⁴⁵⁶⁷⁸⁹⁰⁽⁾⁻⁺⁼'
let s:sub_chars = '                          ₐ ꜀ ₑ  ₕᵢⱼₖₗₘₙₒₚ ᵣₛₜᵤᵥ ₓᵧ ₁₂₃₄₅₆₇₈₉₀₍₎₋₊₌'

let g:SUBSUP_mode = 'normal'

function! SUBSUP_off ()
    silent! iunmap <buffer><nowait> A
    silent! iunmap <buffer><nowait> B
    silent! iunmap <buffer><nowait> C
    silent! iunmap <buffer><nowait> D
    silent! iunmap <buffer><nowait> E
    silent! iunmap <buffer><nowait> F
    silent! iunmap <buffer><nowait> G
    silent! iunmap <buffer><nowait> H
    silent! iunmap <buffer><nowait> I
    silent! iunmap <buffer><nowait> J
    silent! iunmap <buffer><nowait> K
    silent! iunmap <buffer><nowait> L
    silent! iunmap <buffer><nowait> M
    silent! iunmap <buffer><nowait> N
    silent! iunmap <buffer><nowait> O
    silent! iunmap <buffer><nowait> P
    silent! iunmap <buffer><nowait> Q
    silent! iunmap <buffer><nowait> R
    silent! iunmap <buffer><nowait> S
    silent! iunmap <buffer><nowait> T
    silent! iunmap <buffer><nowait> U
    silent! iunmap <buffer><nowait> V
    silent! iunmap <buffer><nowait> W
    silent! iunmap <buffer><nowait> X
    silent! iunmap <buffer><nowait> Y
    silent! iunmap <buffer><nowait> Z
    silent! iunmap <buffer><nowait> a
    silent! iunmap <buffer><nowait> b
    silent! iunmap <buffer><nowait> c
    silent! iunmap <buffer><nowait> d
    silent! iunmap <buffer><nowait> e
    silent! iunmap <buffer><nowait> f
    silent! iunmap <buffer><nowait> g
    silent! iunmap <buffer><nowait> h
    silent! iunmap <buffer><nowait> i
    silent! iunmap <buffer><nowait> j
    silent! iunmap <buffer><nowait> k
    silent! iunmap <buffer><nowait> l
    silent! iunmap <buffer><nowait> m
    silent! iunmap <buffer><nowait> n
    silent! iunmap <buffer><nowait> o
    silent! iunmap <buffer><nowait> p
    silent! iunmap <buffer><nowait> q
    silent! iunmap <buffer><nowait> r
    silent! iunmap <buffer><nowait> s
    silent! iunmap <buffer><nowait> t
    silent! iunmap <buffer><nowait> u
    silent! iunmap <buffer><nowait> v
    silent! iunmap <buffer><nowait> w
    silent! iunmap <buffer><nowait> x
    silent! iunmap <buffer><nowait> y
    silent! iunmap <buffer><nowait> z
    silent! iunmap <buffer><nowait> 1
    silent! iunmap <buffer><nowait> 2
    silent! iunmap <buffer><nowait> 3
    silent! iunmap <buffer><nowait> 4
    silent! iunmap <buffer><nowait> 5
    silent! iunmap <buffer><nowait> 6
    silent! iunmap <buffer><nowait> 7
    silent! iunmap <buffer><nowait> 8
    silent! iunmap <buffer><nowait> 9
    silent! iunmap <buffer><nowait> 0
    silent! iunmap <buffer><nowait> (
    silent! iunmap <buffer><nowait> )
    silent! iunmap <buffer><nowait> -
    silent! iunmap <buffer><nowait> +
    silent! iunmap <buffer><nowait> =
    silent! iunmap <buffer><nowait> <ESC>
    let g:SUBSUP_mode = 'normal'
    return "\<ESC>"
endfunction

function! SUBSUP_sup ()
    if g:SUBSUP_mode == 'sup'
        call SUBSUP_off()
    else
        inoremap <buffer><nowait>  A ᴬ
        inoremap <buffer><nowait>  B ᴮ
        inoremap <buffer><nowait>  C <Nop>
        inoremap <buffer><nowait>  D ᴰ
        inoremap <buffer><nowait>  E ᴱ
        inoremap <buffer><nowait>  F <Nop>
        inoremap <buffer><nowait>  G ᴳ
        inoremap <buffer><nowait>  H ᴴ
        inoremap <buffer><nowait>  I ᴵ
        inoremap <buffer><nowait>  J ᴶ
        inoremap <buffer><nowait>  K ᴷ
        inoremap <buffer><nowait>  L ᴸ
        inoremap <buffer><nowait>  M ᴹ
        inoremap <buffer><nowait>  N ᴺ
        inoremap <buffer><nowait>  O ᴼ
        inoremap <buffer><nowait>  P ᴾ
        inoremap <buffer><nowait>  Q <Nop>
        inoremap <buffer><nowait>  R ᴿ
        inoremap <buffer><nowait>  S ˢ
        inoremap <buffer><nowait>  T ᵀ
        inoremap <buffer><nowait>  U ᵁ
        inoremap <buffer><nowait>  V ⱽ
        inoremap <buffer><nowait>  W ᵂ
        inoremap <buffer><nowait>  X ˣ
        inoremap <buffer><nowait>  Y <Nop>
        inoremap <buffer><nowait>  Z ᶻ
        inoremap <buffer><nowait>  a ª
        inoremap <buffer><nowait>  b ᵇ
        inoremap <buffer><nowait>  c ᶜ
        inoremap <buffer><nowait>  d ᵈ
        inoremap <buffer><nowait>  e ᵉ
        inoremap <buffer><nowait>  f ᶠ
        inoremap <buffer><nowait>  g ᵍ
        inoremap <buffer><nowait>  h ʰ
        inoremap <buffer><nowait>  i ⁱ
        inoremap <buffer><nowait>  j ʲ
        inoremap <buffer><nowait>  k ᵏ
        inoremap <buffer><nowait>  l ˡ
        inoremap <buffer><nowait>  m ᵐ
        inoremap <buffer><nowait>  n ⁿ
        inoremap <buffer><nowait>  o ᵒ
        inoremap <buffer><nowait>  p ᵖ
        inoremap <buffer><nowait>  q <Nop>
        inoremap <buffer><nowait>  r ʳ
        inoremap <buffer><nowait>  s ˢ
        inoremap <buffer><nowait>  t ᵗ
        inoremap <buffer><nowait>  u ᵘ
        inoremap <buffer><nowait>  v ᵛ
        inoremap <buffer><nowait>  w ʷ
        inoremap <buffer><nowait>  x ˣ
        inoremap <buffer><nowait>  y ʸ
        inoremap <buffer><nowait>  z ᶻ
        inoremap <buffer><nowait>  1 ¹
        inoremap <buffer><nowait>  2 ²
        inoremap <buffer><nowait>  3 ³
        inoremap <buffer><nowait>  4 ⁴
        inoremap <buffer><nowait>  5 ⁵
        inoremap <buffer><nowait>  6 ⁶
        inoremap <buffer><nowait>  7 ⁷
        inoremap <buffer><nowait>  8 ⁸
        inoremap <buffer><nowait>  9 ⁹
        inoremap <buffer><nowait>  0 ⁰
        inoremap <buffer><nowait>  ( ⁽
        inoremap <buffer><nowait>  ) ⁾
        inoremap <buffer><nowait>  - ⁻
        inoremap <buffer><nowait>  + ⁺
        inoremap <buffer><nowait>  = ⁼
        inoremap <buffer><nowait><expr> <ESC> SUBSUP_off()
        let g:SUBSUP_mode = 'sup'
    endif
    return ""
endfunction

function! SUBSUP_sub ()
    if g:SUBSUP_mode == 'sub'
        call SUBSUP_off()
    else
        inoremap <buffer><nowait>  A <Nop>
        inoremap <buffer><nowait>  B <Nop>
        inoremap <buffer><nowait>  C <Nop>
        inoremap <buffer><nowait>  D <Nop>
        inoremap <buffer><nowait>  E <Nop>
        inoremap <buffer><nowait>  F <Nop>
        inoremap <buffer><nowait>  G <Nop>
        inoremap <buffer><nowait>  H <Nop>
        inoremap <buffer><nowait>  I <Nop>
        inoremap <buffer><nowait>  J <Nop>
        inoremap <buffer><nowait>  K <Nop>
        inoremap <buffer><nowait>  L <Nop>
        inoremap <buffer><nowait>  M <Nop>
        inoremap <buffer><nowait>  N <Nop>
        inoremap <buffer><nowait>  O <Nop>
        inoremap <buffer><nowait>  P <Nop>
        inoremap <buffer><nowait>  Q <Nop>
        inoremap <buffer><nowait>  R <Nop>
        inoremap <buffer><nowait>  S <Nop>
        inoremap <buffer><nowait>  T <Nop>
        inoremap <buffer><nowait>  U <Nop>
        inoremap <buffer><nowait>  V <Nop>
        inoremap <buffer><nowait>  W <Nop>
        inoremap <buffer><nowait>  X <Nop>
        inoremap <buffer><nowait>  Y <Nop>
        inoremap <buffer><nowait>  Z <Nop>
        inoremap <buffer><nowait>  a ₐ
        inoremap <buffer><nowait>  b <Nop>
        inoremap <buffer><nowait>  c ꜀
        inoremap <buffer><nowait>  d <Nop>
        inoremap <buffer><nowait>  e  ₑ
        inoremap <buffer><nowait>  f <Nop>
        inoremap <buffer><nowait>  g <Nop>
        inoremap <buffer><nowait>  h ₕ
        inoremap <buffer><nowait>  i ᵢ
        inoremap <buffer><nowait>  j ⱼ
        inoremap <buffer><nowait>  k ₖ
        inoremap <buffer><nowait>  l ₗ
        inoremap <buffer><nowait>  m ₘ
        inoremap <buffer><nowait>  n ₙ
        inoremap <buffer><nowait>  o ₒ
        inoremap <buffer><nowait>  p ₚ
        inoremap <buffer><nowait>  q <Nop>
        inoremap <buffer><nowait>  r ᵣ
        inoremap <buffer><nowait>  s ₛ
        inoremap <buffer><nowait>  t ₜ
        inoremap <buffer><nowait>  u ᵤ
        inoremap <buffer><nowait>  v ᵥ
        inoremap <buffer><nowait>  w <Nop>
        inoremap <buffer><nowait>  x ₓ
        inoremap <buffer><nowait>  y ᵧ
        inoremap <buffer><nowait>  z <Nop>
        inoremap <buffer><nowait>  1 ₁
        inoremap <buffer><nowait>  2 ₂
        inoremap <buffer><nowait>  3 ₃
        inoremap <buffer><nowait>  4 ₄
        inoremap <buffer><nowait>  5 ₅
        inoremap <buffer><nowait>  6 ₆
        inoremap <buffer><nowait>  7 ₇
        inoremap <buffer><nowait>  8 ₈
        inoremap <buffer><nowait>  9 ₉
        inoremap <buffer><nowait>  0 ₀
        inoremap <buffer><nowait>  ( ₍
        inoremap <buffer><nowait>  ) ₎
        inoremap <buffer><nowait>  - ₋
        inoremap <buffer><nowait>  + ₊
        inoremap <buffer><nowait>  = ₌
        inoremap <buffer><nowait><expr> <ESC> SUBSUP_off()
        let g:SUBSUP_mode = 'sub'
    endif
    return ""
endfunction

function! SUBSUP_sup_one ()
    if g:SUBSUP_mode == 'sup'
        call SUBSUP_off()
    else
        inoremap <buffer><nowait>  A ᴬ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  B ᴮ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  C <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  D ᴰ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  E ᴱ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  F <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  G ᴳ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  H ᴴ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  I ᴵ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  J ᴶ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  K ᴷ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  L ᴸ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  M ᴹ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  N ᴺ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  O ᴼ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  P ᴾ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Q <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  R ᴿ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  S ˢ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  T ᵀ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  U ᵁ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  V ⱽ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  W ᵂ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  X ˣ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Y <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Z ᶻ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  a ª<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  b ᵇ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  c ᶜ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  d ᵈ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  e ᵉ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  f ᶠ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  g ᵍ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  h ʰ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  i ⁱ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  j ʲ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  k ᵏ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  l ˡ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  m ᵐ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  n ⁿ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  o ᵒ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  p ᵖ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  q <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  r ʳ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  s ˢ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  t ᵗ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  u ᵘ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  v ᵛ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  w ʷ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  x ˣ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  y ʸ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  z ᶻ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  1 ¹<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  2 ²<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  3 ³<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  4 ⁴<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  5 ⁵<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  6 ⁶<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  7 ⁷<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  8 ⁸<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  9 ⁹<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  0 ⁰<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  ( ⁽<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  ) ⁾<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  - ⁻<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  + ⁺<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  = ⁼<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait><expr> <ESC> SUBSUP_off()
        let g:SUBSUP_mode = 'sup'
    endif
    return ""
endfunction

function! SUBSUP_sub_one ()
    if g:SUBSUP_mode == 'sub'
        call SUBSUP_off()
    else
        inoremap <buffer><nowait>  A <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  B <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  C <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  D <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  E <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  F <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  G <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  H <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  I <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  J <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  K <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  L <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  M <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  N <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  O <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  P <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Q <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  R <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  S <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  T <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  U <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  V <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  W <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  X <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Y <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  Z <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  a ₐ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  b <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  c ꜀<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  d <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  e  ₑ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  f <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  g <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  h ₕ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  i ᵢ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  j ⱼ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  k ₖ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  l ₗ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  m ₘ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  n ₙ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  o ₒ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  p ₚ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  q <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  r ᵣ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  s ₛ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  t ₜ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  u ᵤ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  v ᵥ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  w <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  x ₓ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  y ᵧ<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  z <Nop><C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  1 ₁<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  2 ₂<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  3 ₃<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  4 ₄<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  5 ₅<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  6 ₆<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  7 ₇<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  8 ₈<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  9 ₉<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  0 ₀<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  ( ₍<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  ) ₎<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  - ₋<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  + ₊<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait>  = ₌<C-O>:call SUBSUP_off()<CR>
        inoremap <buffer><nowait><expr> <ESC> SUBSUP_off()
        let g:SUBSUP_mode = 'sub'
    endif
    return ""
endfunction

inoremap <expr> <C-K><C-L>       SUBSUP_sub()
inoremap <expr> <C-K><C-J>       SUBSUP_sup()
inoremap <expr> <C-K><C-L><C-L>  SUBSUP_sub_one()
inoremap <expr> <C-K><C-J><C-J>  SUBSUP_sup_one()

" Restore previous external compatibility options
let &cpo = s:save_cpo
