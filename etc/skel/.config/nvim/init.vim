" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" 基本的に bash のスクリプトを操作するので
let g:is_bash = 1

" mod esc time
set timeoutlen=1000 ttimeoutlen=0

exe 'so ~/.local/misc/etc/nvim/bundle.nvim'
exe 'so ~/.local/misc/etc/vim/encodings'
exe 'so ~/.local/misc/etc/vim/filetypes'
exe 'so ~/.local/misc/etc/vim/basis'

colo slate

"molokai

"syntax enable
"se bg=dark
"let g:solarized_termcolors=256
"colo solarized

" vim:se ft=vim:
