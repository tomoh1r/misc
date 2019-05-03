" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" 基本的に bash のスクリプトを操作するので
let g:is_bash = 1

exe 'so ~/misc/etc/nvim/bundle.nvim'
exe 'so ~/misc/etc/vim/encodings'
exe 'so ~/misc/etc/vim/filetypes'
exe 'so ~/misc/etc/vim/basis'

colo slate

" vim:se ft=vim:
