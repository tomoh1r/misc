" vim: ft=vim:

" Hide toolbar
se guioptions-=T
" Show tab bar always
se showtabline=2
" Hide line number
se nonumber
" disable visual bell
se visualbell t_vb=

if has('win32')
  " Window size
  se columns=132 lines=40
  " Windows's clipboard
  se clipboard=unnamed
  " フォント系
  se guifont=Migu_2M:h12:cSHIFTJIS:qDRAFT
  se ambiwidth=double antialias
endif

" 見た目
"colo dracula
"se background=dark
