" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

let s:myprof = expand('~/AppData/Local/nvim/init.vim')
exe 'so ' . s:myprof

" Hide toolbar
se guioptions-=T
" Show tab bar always
se showtabline=2
" Hide line number
se nonumber
" disable visual bell
se visualbell t_vb=

se columns=132 lines=40
se clipboard=unnamed
"se guifont=Migu_2M:h12:cSHIFTJIS:qDRAFT
se ambiwidth=double

colo morning

" vim:se ft=vim:
